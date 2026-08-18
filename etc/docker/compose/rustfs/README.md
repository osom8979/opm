# RustFS — Self-Hosted S3 for One Directory

A single-node [RustFS](https://github.com/rustfs/rustfs) instance that turns one
host directory into an **S3-compatible endpoint**, with the API and the web
console published on loopback so a reverse proxy or a Cloudflare Tunnel can
decide who reaches them.

---

## Read this before pointing it at a directory

RustFS is a **storage backend, not a filesystem gateway**. Inside
`RUSTFS_DATA_DIR` it keeps a MinIO-compatible layout — buckets as directories,
each object split into data plus an `xl.meta` sidecar. Two consequences:

- **Files already in that directory do not become S3 objects.** To publish an
  existing tree, start with an empty directory and upload into it
  (`./s3 s3 sync ./tree s3://bucket/`).
- **Do not edit the tree on disk behind RustFS's back.** The scanner treats
  mismatched `xl.meta` as corruption and tries to heal it.

If what you actually want is "expose this existing directory as-is over S3",
this stack is the wrong tool — that needs an S3-over-filesystem gateway, which
RustFS is not.

---

## Contents

| File | Purpose |
| --- | --- |
| `docker-compose.yml` | RustFS server + optional bucket bootstrap |
| `env-template` → `.env` | host-specific values and credentials |
| `generate-env` | writes `.env`, generates the root access/secret key |
| `s3` | `aws-cli` wrapper pointed at this stack |
| `data/` | default `RUSTFS_DATA_DIR` (contents gitignored) |

`.env` is gitignored.

---

## Prerequisites

- Docker Engine + compose plugin
- A directory for the data, on a filesystem with real POSIX semantics
  (ext4/XFS — **not** an SMB/NFS mount, which breaks the metadata writes)

---

## Setup

### 1. Generate `.env`

```bash
./generate-env
```

It fills in `USER_UID`/`USER_GID` and generates `RUSTFS_ACCESS_KEY` /
`RUSTFS_SECRET_KEY`, printing them once — they are stored nowhere else.

Leaving the keys unset is not an option worth taking: RustFS falls back to
`rustfsadmin`/`rustfsadmin` and merely *warns* about it.

### 2. Choose the directory

```env
RUSTFS_DATA_DIR=/srv/s3            # absolute, or './data' relative to here
```

It must be writable by `USER_UID:USER_GID` — the container runs as the host
user precisely so a bind mount needs no `chown -R`.

```bash
mkdir -p /srv/s3
```

### 3. Start

```bash
docker compose up -d
docker compose ps
```

---

## Verify

```bash
./s3 s3 mb s3://probe
./s3 s3 ls
echo hello > /tmp/probe.txt && ./s3 s3 cp /tmp/probe.txt s3://probe/   # from /tmp
./s3 s3 ls s3://probe/
./s3 s3 rb s3://probe --force
```

Health and console:

```bash
curl -fsS http://127.0.0.1:9000/health
xdg-open http://127.0.0.1:9001        # log in with the .env credentials
```

The `s3` wrapper mounts `$PWD` at `/work`, so local paths only resolve inside
the directory you run it from.

---

## Client settings that matter

| Setting | Value | Why |
| --- | --- | --- |
| Addressing style | **path** | a custom endpoint has no wildcard DNS behind it, so `bucket.host` resolves nowhere |
| Region | `RUSTFS_REGION` (`us-east-1`) | SigV4 signs it; a mismatch is a signature error |
| Signature | v4 | the only version RustFS accepts |
| Checksums | `when_required` | AWS SDKs ≥ 2025 default to `aws-chunked` bodies with no `Content-Length`, which RustFS rejects on `UploadPart` |

For boto3/AWS CLI that is:

```bash
export AWS_S3_ADDRESSING_STYLE=path
export AWS_REQUEST_CHECKSUM_CALCULATION=when_required
export AWS_RESPONSE_CHECKSUM_VALIDATION=when_required
```

To enable virtual-hosted-style (`bucket.s3.example.com`) instead, set
`RUSTFS_SERVER_DOMAINS` in `docker-compose.yml` **and** add wildcard DNS. The
consumers in this repo do not need it — `../registry` pins
`forcepathstyle: true` for exactly this reason.

---

## Exposing it

Both listeners bind to `${BIND_ADDRESS}` — `127.0.0.1` by default — so nothing
off this host reaches them until something is put in front:

- **Reverse proxy** (the shared `../caddy` stack) terminates TLS for a public
  name and forwards to `127.0.0.1:9000`. It must not rewrite the `Host` header:
  SigV4 signs it, and a rewrite shows up as `SignatureDoesNotMatch`.
- **Cloudflare Tunnel** — what `../registry` expects on the other end. Two
  constraints: nothing may rewrite `Host`, and the hostname must not sit behind
  an Access policy, because an S3 SDK cannot complete a browser login flow.
  Bodies through the tunnel are capped by the Cloudflare proxy (100 MB on
  Free/Pro), so clients must keep multipart parts under it — `../registry` does
  this with `S3_CHUNKSIZE`.

Publish the **console** port (9001) to anything wider only if you mean to; it
authenticates with the same root credentials as the API. Otherwise set
`RUSTFS_CONSOLE_ENABLE=false`.

---

## Operating

**Bootstrap buckets at startup** — list them in `.env`, space separated:

```env
S3_BUCKETS=registry backups
```

`create-bucket` runs after the server is healthy and skips buckets that exist.

**Rotate the root credentials** — edit `.env`, then
`docker compose up -d rustfs`. Every consumer has to be updated in the same
pass; these are root keys, not per-application ones.

**Logs** — stdout, capped at 10 × 10 MB by the json-file driver:

```bash
docker compose logs -f rustfs
```

Raise the detail with `RUSTFS_LOG_LEVEL=debug` in `.env`.

**Raise the file descriptor limit** — RustFS wants 512 fds per drive and logs
`std fd cache disabled: RLIMIT_NOFILE soft limit too low` when it cannot have
them, falling back to open-per-read. Harmless, but it costs throughput; fix it
by adding to the `rustfs` service:

```yaml
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
```

**Back up** — back up `RUSTFS_DATA_DIR` while the server is stopped, or
replicate through S3 (`./s3 s3 sync s3://bucket /elsewhere`). A snapshot of a
running data directory can catch a half-written `xl.meta`.

---

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| Container restarts, `Permission denied` on `/data` | `RUSTFS_DATA_DIR` is not writable by `USER_UID:USER_GID` |
| `WARNING: ... uses the default rustfsadmin credential` | `.env` was not generated, or the keys are empty |
| `SignatureDoesNotMatch` | something rewrote the `Host` header, or the client's region differs from `RUSTFS_REGION` |
| `MissingContentLength` on `UploadPart` | client sent an `aws-chunked` body — set the two checksum env vars to `when_required` |
| `NoSuchBucket` for a name that resolves in a browser | client is using virtual-hosted style; force path-style |
| Existing files in the directory are invisible | expected — see the note at the top |
| `413` through a Cloudflare Tunnel | the proxy body cap; lower the client's multipart part size |

---

## Shutdown

```bash
docker compose down       # data stays in RUSTFS_DATA_DIR
```

---

## References

- RustFS: <https://github.com/rustfs/rustfs>
- Docs: <https://docs.rustfs.com>
- Environment variables: <https://docs.rustfs.com/en/reference/environment-variables>
- Image tags: <https://hub.docker.com/r/rustfs/rustfs/tags>
