#!/usr/bin/env bash
# Run the KakaoTalk-in-Wine container on the host's current X11 display.
#
#   Env overrides:
#     KAKAO_IMAGE   image tag to run       (default: osom8979/kakaotalk:latest)
#     KAKAO_VOLUME  wine prefix volume     (default: kakaotalk-wine)
#     KAKAO_SILENT  1 = unattended install (default: 0, GUI installer)

set -euo pipefail

IMAGE="${KAKAO_IMAGE:-osom8979/kakaotalk:latest}"
VOLUME="${KAKAO_VOLUME:-kakaotalk-wine}"

: "${DISPLAY:?DISPLAY is not set; run this from an X11 desktop session}"

# Let containers connect to the local X server.
if command -v xhost &> /dev/null; then
    xhost +local:docker > /dev/null || true
fi

exec docker run --rm -it \
    --name kakaotalk \
    -e DISPLAY="$DISPLAY" \
    -e KAKAO_SILENT="${KAKAO_SILENT:-0}" \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v "$VOLUME":/root/.wine \
    "$IMAGE" "$@"
