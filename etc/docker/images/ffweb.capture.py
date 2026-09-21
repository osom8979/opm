"""
mitmproxy addon: 브라우저가 받은 동영상을 로컬에서 재생 가능한 구조로 저장한다.

- Progressive (MP4/WebM/...): URL 경로를 그대로 미러링하여 저장한다.
  206 Range 응답은 Content-Range 오프셋에 기록하고, 필요하면 전체를 백그라운드로 받는다.
- HLS: m3u8 의 모든 URI 를 로컬 상대 경로로 치환하여 저장하고,
  세그먼트/키/init(MAP) 은 치환된 경로에 그대로 저장한다.
  Live/Sliding window 플레이리스트는 MEDIA-SEQUENCE 기준으로 누적한다.

환경변수:
  FFCAP_DIR         저장 경로 (기본: /config/captures)
  FFCAP_FULL_FETCH  1 이면 Range 로 일부만 받은 Progressive 파일을 전체 다운로드 (기본: 1)
"""

import hashlib
import json
import os
import re
import threading
import time
import urllib.request
from urllib.parse import unquote, urljoin, urlsplit

from mitmproxy import ctx, http

ROOT = os.environ.get("FFCAP_DIR", "/config/captures")
FULL_FETCH = os.environ.get("FFCAP_FULL_FETCH", "1") == "1"

MEDIA_EXTS = {
    ".mp4", ".m4v", ".m4a", ".m4s", ".mov", ".webm", ".mkv", ".ogg", ".ogv", ".oga",
    ".opus", ".mp3", ".aac", ".flac", ".wav", ".ts", ".mts", ".m2ts", ".cmfv", ".cmfa",
}  # fmt: skip
PLAYLIST_EXTS = {".m3u8", ".m3u"}
PLAYLIST_TYPES = ("mpegurl", "x-mpegurl")
CTYPE_EXTS = {
    "video/mp4": ".mp4", "video/webm": ".webm", "video/ogg": ".ogv", "video/mp2t": ".ts",
    "video/quicktime": ".mov", "video/x-matroska": ".mkv", "audio/mp4": ".m4a",
    "audio/webm": ".weba", "audio/ogg": ".oga", "audio/mpeg": ".mp3", "audio/aac": ".aac",
}  # fmt: skip
URI_ATTR = re.compile(r'URI="([^"]*)"')
UNSAFE = re.compile(r'[\x00-\x1f<>:"\\|?*%]')
DROP_TAGS = (
    "#EXT-X-PART", "#EXT-X-PRELOAD-HINT", "#EXT-X-SERVER-CONTROL", "#EXT-X-PART-INF",
    "#EXT-X-RENDITION-REPORT", "#EXT-X-SKIP", "#EXT-X-MEDIA-SEQUENCE", "#EXT-X-ENDLIST",
    "#EXT-X-PLAYLIST-TYPE", "#EXT-X-BITRATE", "#EXT-X-DATERANGE",
)  # fmt: skip


def _ctype(headers) -> str:
    return headers.get("content-type", "").split(";")[0].strip().lower()


def _ext(url: str) -> str:
    return os.path.splitext(urlsplit(url).path)[1].lower()


def _component(name: str) -> str:
    name = UNSAFE.sub("_", name)
    if name in ("", ".", ".."):
        name = "_"
    if len(name.encode()) > 150:
        stem, ext = os.path.splitext(name)
        name = stem[:100] + "_" + hashlib.sha1(name.encode()).hexdigest()[:8] + ext[:16]
    return name


def local_path(url: str, ctype: str = "") -> str:
    """URL 을 ROOT/<host>/<path> 로 매핑한다. 같은 URL 은 항상 같은 경로가 된다."""
    s = urlsplit(url)
    host = s.hostname or "_"
    if s.port and s.port not in (80, 443):
        host += f"_{s.port}"
    parts = [p for p in unquote(s.path).split("/")]
    if not parts[-1]:
        parts[-1] = "index"
    parts = [_component(p) for p in parts if p]
    stem, ext = os.path.splitext(parts[-1])
    if not ext and ctype in CTYPE_EXTS:
        ext = CTYPE_EXTS[ctype]
    if s.query:
        stem += "_" + hashlib.sha1(s.query.encode()).hexdigest()[:10]
    parts[-1] = stem + ext
    return os.path.join(ROOT, _component(host), *parts)


def playlist_path(url: str) -> str:
    path = local_path(url)
    return path if path.endswith(tuple(PLAYLIST_EXTS)) else path + ".m3u8"


def _is_http(url: str) -> bool:
    return url.startswith(("http://", "https://"))


class RangeWriter:
    """Content-Range 오프셋에 맞춰 파일에 기록한다."""

    def __init__(self, path: str, offset: int):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        fd = os.open(path, os.O_RDWR | os.O_CREAT, 0o644)
        self.file = os.fdopen(fd, "r+b", buffering=0)
        self.file.seek(offset)

    def __call__(self, data: bytes) -> bytes:
        if self.file.closed:
            return data
        if data:
            self.file.write(data)
        else:
            self.file.close()
        return data


class Capture:
    def __init__(self):
        self.lock = threading.Lock()
        self.wanted: set[str] = set()  # 플레이리스트가 참조한 URL (세그먼트/키/MAP)
        self.playlists: dict[str, dict] = {}  # 로컬 경로 -> 누적 상태
        self.full_fetched: set[str] = set()
        os.makedirs(ROOT, exist_ok=True)

    # ------------------------------------------------------------------ utils

    def log(self, **kw):
        kw["time"] = time.strftime("%Y-%m-%d %H:%M:%S")
        with self.lock, open(os.path.join(ROOT, "_index.jsonl"), "a") as f:
            f.write(json.dumps(kw, ensure_ascii=False) + "\n")

    @staticmethod
    def write(path: str, data: bytes | str):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        tmp = path + ".tmp"
        with open(tmp, "wb") as f:
            f.write(data.encode() if isinstance(data, str) else data)
        os.replace(tmp, path)

    @staticmethod
    def is_playlist(flow: http.HTTPFlow) -> bool:
        ctype = _ctype(flow.response.headers)
        return ctype.endswith(PLAYLIST_TYPES) or _ext(flow.request.url) in PLAYLIST_EXTS

    def is_media(self, flow: http.HTTPFlow) -> bool:
        url = flow.request.url
        ctype = _ctype(flow.response.headers)
        if url in self.wanted:
            return True
        if ctype.startswith(("video/", "audio/")) or ctype == "application/dash+xml":
            return True
        return _ext(url) in MEDIA_EXTS and not ctype.startswith(("text/html", "image/"))

    # ------------------------------------------------------------------ hooks

    def responseheaders(self, flow: http.HTTPFlow):
        resp = flow.response
        if resp.status_code not in (200, 206) or self.is_playlist(flow):
            return
        if not self.is_media(flow):
            return
        encoding = resp.headers.get("content-encoding", "identity").lower()
        if encoding not in ("", "identity"):
            flow.metadata["ffcap_buffered"] = True  # 압축된 응답은 response 훅에서 디코딩 후 저장
            return

        url = flow.request.url
        is_segment = url in self.wanted
        path = local_path(url, "" if is_segment else _ctype(resp.headers))
        offset = 0
        m = re.match(r"bytes (\d+)-(\d+)/(\d+|\*)", resp.headers.get("content-range", ""))
        if resp.status_code == 206 and m:
            offset = int(m.group(1))
        resp.stream = RangeWriter(path, offset)
        self.log(kind="segment" if is_segment else "media", url=url, path=path,
                 status=resp.status_code, range=resp.headers.get("content-range", ""),
                 ctype=_ctype(resp.headers), referer=flow.request.headers.get("referer", ""))  # fmt: skip

        if not is_segment:
            flow.metadata["ffcap_path"] = path
            # 일부 Range 만 받은 경우 나머지를 채우기 위해 전체를 받는다 (중단된 경우는 error 훅에서)
            if m and m.group(3) != "*" and not (m.group(1) == "0" and int(m.group(2)) + 1 == int(m.group(3))):
                self.full_fetch_async(flow)

    def error(self, flow: http.HTTPFlow):
        if flow.response and isinstance(flow.response.stream, RangeWriter):
            flow.response.stream(b"")
        if flow.metadata.get("ffcap_path"):
            self.full_fetch_async(flow)  # 브라우저가 연결을 중간에 끊음

    def response(self, flow: http.HTTPFlow):
        resp = flow.response
        if resp.stream or resp.status_code not in (200, 206):
            return
        url = flow.request.url
        if flow.metadata.get("ffcap_buffered") or url in self.wanted:
            path = local_path(url, "" if url in self.wanted else _ctype(resp.headers))
            self.write(path, resp.content or b"")
            self.log(kind="segment" if url in self.wanted else "media", url=url, path=path,
                     status=resp.status_code, ctype=_ctype(resp.headers))  # fmt: skip
            return
        if self.is_playlist(flow) or resp.raw_content[:16].lstrip(b"\xef\xbb\xbf \r\n").startswith(b"#EXTM3U"):
            try:
                text = resp.get_text(strict=False) or ""
            except ValueError:
                return
            if text.lstrip("﻿ \r\n").startswith("#EXTM3U"):
                self.on_playlist(url, text)

    # ------------------------------------------------------------------ progressive

    def full_fetch_async(self, flow: http.HTTPFlow):
        url = flow.request.url
        if not FULL_FETCH or url in self.full_fetched:
            return
        self.full_fetched.add(url)
        skip = ("range", "if-range", "accept-encoding", "host", "connection")
        headers = {k: v for k, v in flow.request.headers.items() if k.lower() not in skip}
        threading.Thread(target=self.full_fetch, args=(url, headers, flow.metadata["ffcap_path"]), daemon=True).start()

    def full_fetch(self, url: str, headers: dict, path: str):
        try:
            req = urllib.request.Request(url, headers=headers)
            opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
            with opener.open(req, timeout=60) as r:
                writer = RangeWriter(path, 0)
                while chunk := r.read(1 << 20):
                    writer(chunk)
                writer(b"")
            self.log(kind="full_fetch", url=url, path=path, status="done")
        except Exception as e:
            ctx.log.warn(f"[ffcap] full fetch failed: {url}: {e}")
            self.log(kind="full_fetch", url=url, path=path, status=f"error: {e}")

    # ------------------------------------------------------------------ HLS

    def rewrite(self, base_url: str, pl_dir: str, uri: str, playlist: bool = False) -> str:
        """플레이리스트 안의 URI 를 로컬 상대 경로로 바꾸고, 세그먼트면 수집 대상으로 등록한다."""
        abs_url = urljoin(base_url, uri.strip())
        if not _is_http(abs_url):
            return uri
        if playlist:
            return os.path.relpath(playlist_path(abs_url), pl_dir)
        with self.lock:
            self.wanted.add(abs_url)
        return os.path.relpath(local_path(abs_url), pl_dir)

    def on_playlist(self, url: str, text: str):
        path = playlist_path(url)
        pl_dir = os.path.dirname(path)
        lines = text.lstrip("﻿").splitlines()

        def attr(ln: str) -> str:
            return URI_ATTR.sub(lambda m: f'URI="{self.rewrite(url, pl_dir, m.group(1))}"', ln)

        if any(ln.startswith(("#EXT-X-STREAM-INF", "#EXT-X-MEDIA:", "#EXT-X-I-FRAME-STREAM-INF")) for ln in lines):
            out = []
            for ln in lines:
                ln = ln.strip()
                if ln.startswith(("#EXT-X-MEDIA:", "#EXT-X-I-FRAME-STREAM-INF")):
                    ln = URI_ATTR.sub(lambda m: f'URI="{self.rewrite(url, pl_dir, m.group(1), True)}"', ln)
                    out.append(ln)
                elif ln.startswith("#"):
                    out.append(attr(ln))
                elif ln:
                    out.append(self.rewrite(url, pl_dir, ln, True))
            self.write(path, "\n".join(out) + "\n")
            self.log(kind="master", url=url, path=path)
            return

        # Media playlist: 세그먼트를 MEDIA-SEQUENCE 기준으로 누적
        with self.lock:
            st = self.playlists.setdefault(path, {"header": None, "segments": {}, "endlist": False})
        header, seq, key, cmap, pending, seen = [], 0, None, None, [], False
        for ln in lines:
            ln = ln.strip()
            if not ln:
                continue
            if ln.startswith("#EXT-X-MEDIA-SEQUENCE:"):
                seq = int(ln.split(":", 1)[1])
            elif ln.startswith("#EXT-X-ENDLIST"):
                st["endlist"] = True
            elif ln.startswith(DROP_TAGS):
                continue
            elif ln.startswith("#EXT-X-KEY"):
                key = attr(ln)
            elif ln.startswith("#EXT-X-MAP"):
                cmap = attr(ln)
            elif ln.startswith(("#EXTINF", "#EXT-X-BYTERANGE", "#EXT-X-DISCONTINUITY", "#EXT-X-PROGRAM-DATE-TIME", "#EXT-X-GAP")):
                pending.append(ln)
            elif ln.startswith("#"):
                if not seen and not pending:
                    header.append(ln)
            else:
                st["segments"][seq] = (key, cmap, pending, self.rewrite(url, pl_dir, ln))
                seq, pending, seen = seq + 1, [], True
        if st["header"] is None:
            st["header"] = header

        out = list(st["header"])
        seqs = sorted(st["segments"])
        out.append("#EXT-X-PLAYLIST-TYPE:VOD")
        out.append(f"#EXT-X-MEDIA-SEQUENCE:{seqs[0] if seqs else 0}")
        last_key = last_map = prev = None
        for s in seqs:
            key, cmap, tags, uri = st["segments"][s]
            if prev is not None and s != prev + 1 and "#EXT-X-DISCONTINUITY" not in tags:
                out.append("#EXT-X-DISCONTINUITY")  # 누락된 구간
            if key != last_key:
                out.append(key or "#EXT-X-KEY:METHOD=NONE")
                last_key = key
            if cmap and cmap != last_map:
                out.append(cmap)
                last_map = cmap
            out.extend(tags)
            out.append(uri)
            prev = s
        out.append("#EXT-X-ENDLIST")
        self.write(path, "\n".join(out) + "\n")
        self.log(kind="playlist", url=url, path=path, segments=len(seqs))


addons = [Capture()]
