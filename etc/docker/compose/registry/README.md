# Docker Registry with S3 Behind a Cloudflare Tunnel

A self-hosted OCI registry (**CNCF Distribution v3**) that keeps its blobs on a
**remote S3-compatible store reached through a Cloudflare Tunnel**, with bcrypt
basic auth.

---

## Why the topology looks like this

Cloudflare's proxy caps request bodies — **100 MB on Free/Pro, 200 MB on
Business, 500 MB on Enterprise**, and returns `413` past that. Tunnels are no
exception: a tunnel's public hostname is always proxied, so it inherits the cap.

`docker push` sends an entire layer in **one** request and gives you no way to
split it, so a proxied registry hostname breaks on the first layer over the cap.
The storage leg is the opposite case: **the registry — not the client — picks
the multipart part size**, so it can stay under the cap forever.

Hence the split:

```
 docker push
     |
     |  no size cap: DNS-only (grey cloud), TLS terminated by the local proxy
     v
 registry  (this stack, listening on 127.0.0.1:5000)
     |
     |  32 MiB multipart parts, HTTPS
     v
 Cloudflare edge  ->  cloudflared  ->  S3   (remote site)
```

The front door **must stay off the Cloudflare proxy**. Everything else here is
just making the storage leg behave.

---

## Contents

| File | Purpose |
| --- | --- |
| `docker-compose.yml` | registry + bucket bootstrap |
| `config/config.yml` | Distribution config: structure and tuning rationale |
| `env-template` → `.env` | host-specific values and secrets |
| `generate-env` | writes `.env`, generates `REGISTRY_HTTP_SECRET` |
| `generate-htpasswd` | writes `htpasswd` (bcrypt — the only format v3 accepts) |

`.env` and `htpasswd` are gitignored.

The reverse proxy in front is **not** part of this stack — the registry binds
`127.0.0.1:${REGISTRY_PORT}` and whatever proxy this host already runs (e.g. the
shared `../caddy` stack) terminates TLS for `REGISTRY_DOMAIN` and forwards there.
Two things that proxy must not do: cap the request body size, and buffer
requests. Caddy satisfies both by default; nginx needs
`client_max_body_size 0;` and `proxy_request_buffering off;`.

---

## Prerequisites

- Docker Engine + compose plugin
- A DNS name for the registry that is **DNS-only (grey cloud)** in Cloudflare
- A reachable S3-compatible store (RustFS, SeaweedFS, Garage, Ceph RGW, R2 …)
  and its credentials
- A Cloudflare Tunnel already published in front of that S3. Two constraints on
  it matter here: nothing may rewrite the `Host` header (SigV4 signs it), and
  the hostname must not sit behind an Access policy (an S3 SDK cannot complete a
  browser login flow).

---

## Setup

### 1. Generate `.env`

```bash
./generate-env
```

It fills in `USER_UID`/`USER_GID`, generates `REGISTRY_HTTP_SECRET`, and guesses
`REGISTRY_DOMAIN` from the hostname. It then prints the placeholders you must
edit by hand:

- `S3_ENDPOINT_URL` — the **tunnel** hostname, e.g. `https://s3-xxxx.example.com`
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` — credentials of the remote S3

### 2. Create a user

```bash
./generate-htpasswd ci-pusher            # prints a generated password
./generate-htpasswd alice 'own-password'  # or set one
```

Distribution accepts **bcrypt only**; a differently-hashed entry is ignored
silently and looks exactly like a wrong password.

### 3. Start

```bash
docker compose up -d
```

`create-bucket` runs first and creates the bucket if needed. It passing is the
first real proof that the tunnel and SigV4 path work end to end.

---

## Verify

```bash
# 1. tunnel + signing path (from this host)
docker compose run --rm create-bucket

# 2. auth
docker login registry.example.com -u ci-pusher

# 3. the thing this stack exists for: a layer well over 100 MB
dd if=/dev/urandom of=/tmp/big bs=1M count=250
printf 'FROM scratch\nCOPY big /big\n' > /tmp/Dockerfile
docker build -t registry.example.com/probe:1 -f /tmp/Dockerfile /tmp
docker push registry.example.com/probe:1

# 4. round trip
docker rmi registry.example.com/probe:1
docker pull registry.example.com/probe:1
```

If step 3 succeeds, the 100 MB wall is genuinely gone. While it runs:

```bash
docker compose logs -f registry
docker compose exec registry wget -qO- http://127.0.0.1:5001/debug/health
```

---

## Tuning the part size

`S3_CHUNKSIZE` sits between three bounds:

| Bound | Value |
| --- | --- |
| S3 minimum part size | 5 MiB |
| Cloudflare body cap | 100 MB Free/Pro · 200 MB Business · 500 MB Enterprise |
| Proxy Read Timeout | one part must finish inside ~100 s |

So the uplink at the S3 site needs at least `chunksize / 100 s`:

| `S3_CHUNKSIZE` | Minimum uplink | Comfortable uplink |
| --- | --- | --- |
| 8 MiB (`8388608`) | 0.7 Mbps | 3 Mbps |
| 16 MiB (`16777216`) | 1.4 Mbps | 5 Mbps |
| **32 MiB (`33554432`)** — default | 2.7 Mbps | 10 Mbps |
| 64 MiB (`67108864`) | 5.4 Mbps | 20 Mbps |

Bigger parts mean fewer round trips but a more expensive retry when one fails.
32 MiB is the sane default; drop it if the S3 site's uplink is thin.

`S3_MULTIPART_COPY_MAXCONCURRENCY` is separate. Blob commit moves the staged
upload with a **server-side** multipart copy — no request body, so the cap does
not apply — but Distribution's default of **100 concurrent part operations**
stampedes a single cloudflared process. It ships here at `8`; raise it toward 16
only if you have watched cloudflared's metrics stay clean.

---

## Operating

**Add or rotate a user** — rerun `./generate-htpasswd <user> [password]`
(existing users are replaced), then `docker compose restart registry`.

**Reclaim deleted blobs** — deletion is enabled, but space only comes back on a
garbage collect:

```bash
docker compose exec registry \
  registry garbage-collect /etc/distribution/config.yml --delete-untagged
```

Run it when nothing is pushing: GC does not coordinate with in-flight uploads.
Add `--dry-run` first to see what it would remove.

**Inspect the effective config** — v3 dropped `registry validate`, so config
errors show up at boot:

```bash
docker compose logs registry                        # parse/boot errors
docker compose exec registry env | grep ^REGISTRY_  # which overrides are live
```

**Metrics** — Prometheus on the container-local debug listener,
`http://127.0.0.1:5001/metrics` inside the container. Never publish that port.

---

## Known limitation: cold pulls cross the tunnel

Distribution caches blob *descriptors*, not blob *bodies*. Every pull of a layer
that isn't already on the node is a full round trip through the tunnel, and a
fleet of Kubernetes nodes pulling a multi-GB CUDA image at once will find
cloudflared before it finds a bandwidth limit.

Mitigations, in increasing order of effort: run 2–4 cloudflared replicas of the
same tunnel; pre-pull hot base images onto nodes; put a pull-through cache in
front of the registry; or — the real fix — move the registry to the same site as
the S3 store and drop the tunnel from the hot path entirely.

---

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| `413 Request Entity Too Large` on push | the registry hostname is proxied (orange cloud). Make it DNS-only. |
| `413` with a direct front door | the proxy caps bodies (nginx `client_max_body_size`), or `S3_CHUNKSIZE` exceeds the plan's cap |
| `524` mid-upload | one part is slower than the ~100 s Proxy Read Timeout → lower `S3_CHUNKSIZE` |
| `MissingContentLength` on `UploadPart` | the checksum env vars are missing; aws-sdk-go-v2 sends aws-chunked bodies with no `Content-Length` and RustFS/MinIO rejects them |
| `SignatureDoesNotMatch` | something rewrote the `Host` header between registry and S3 |
| `InvalidBucketName` / 404 on the bucket | `forcepathstyle` got turned off — v3 defaults it to `false`, and a custom endpoint has no wildcard DNS |
| `docker login` fails with a correct password | the `htpasswd` entry is not bcrypt |
| Container `unhealthy`, pushes fail | `health.storagedriver` is red, i.e. S3 is unreachable — check the tunnel first |
| Random stalls on blob commit | `S3_MULTIPART_COPY_MAXCONCURRENCY` too high for one cloudflared |

---

## Shutdown

```bash
docker compose down       # keeps the blobs -- they live in S3
```
