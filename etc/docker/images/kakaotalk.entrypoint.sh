#!/usr/bin/env bash
# Bootstrap the wine prefix, install KakaoTalk on first run, then launch it on
# the X11 display provided by the host ($DISPLAY).

set -euo pipefail

: "${WINEPREFIX:=/root/.wine}"
: "${WINEARCH:=win64}"
: "${KAKAO_SETUP_PATH:=/opt/kakaotalk/KakaoTalk_Setup.exe}"
export WINEPREFIX WINEARCH

KAKAO_EXE="$WINEPREFIX/drive_c/Program Files/Kakao/KakaoTalk/KakaoTalk.exe"

if [[ -z "${DISPLAY:-}" ]]; then
    echo "[kakaotalk] WARN: DISPLAY is empty; the GUI has nowhere to render." >&2
    echo "[kakaotalk] Pass -e DISPLAY and mount /tmp/.X11-unix (see kakaotalk.run.sh)." >&2
fi

# Initialize the wine prefix on a fresh (empty) volume.
if [[ ! -f "$WINEPREFIX/system.reg" ]]; then
    echo "[kakaotalk] Initializing wine prefix at $WINEPREFIX ..."
    wineboot --init
    wineserver -w
fi

# Expose the bundled Nanum fonts to GDI so Korean text renders in dialogs.
FONTS_DST="$WINEPREFIX/drive_c/windows/Fonts"
mkdir -p "$FONTS_DST"
for f in /usr/share/fonts/truetype/nanum/*.ttf; do
    [[ -e "$f" ]] && ln -sf "$f" "$FONTS_DST/"
done

# Install KakaoTalk when it is not present in the prefix yet.
if [[ ! -f "$KAKAO_EXE" ]]; then
    echo "[kakaotalk] KakaoTalk not found; running installer ..."
    if [[ "${KAKAO_SILENT:-0}" == "1" ]]; then
        # KakaoTalk_Setup.exe is NSIS-based; /S attempts an unattended install.
        wine "$KAKAO_SETUP_PATH" /S || true
    else
        wine "$KAKAO_SETUP_PATH" || true
    fi
    wineserver -w
fi

if [[ ! -f "$KAKAO_EXE" ]]; then
    echo "[kakaotalk] ERROR: KakaoTalk.exe not found after install attempt." >&2
    echo "[kakaotalk] Expected: $KAKAO_EXE" >&2
    echo "[kakaotalk] Re-run without KAKAO_SILENT=1 to use the GUI installer." >&2
    exit 1
fi

echo "[kakaotalk] Launching KakaoTalk ..."
exec wine "$KAKAO_EXE" "$@"
