#!/usr/bin/env bash
# Run the KakaoTalk-in-Wine container on the host's current X11 display.
#
#   Env overrides:
#     KAKAO_IMAGE   image tag to run       (default: osom8979/kakaotalk:latest)
#     KAKAO_VOLUME  wine prefix volume     (default: kakaotalk-wine)
#     KAKAO_SHARE   shared host directory  (default: $HOME/Downloads/KakaoTalk)
#     KAKAO_SILENT  1 = unattended install (default: 0, GUI installer)

set -euo pipefail

IMAGE="${KAKAO_IMAGE:-osom8979/kakaotalk:latest}"
VOLUME="${KAKAO_VOLUME:-kakaotalk-wine}"
SHARE="${KAKAO_SHARE:-$HOME/Downloads/KakaoTalk}"

: "${DISPLAY:?DISPLAY is not set; run this from an X11 desktop session}"

mkdir -p "$SHARE"

# Let containers connect to the local X server.
if command -v xhost &> /dev/null; then
    xhost +local:docker > /dev/null || true
fi

ARGS=(
    --rm -it
    --name kakaotalk
    -e DISPLAY="$DISPLAY"
    -e KAKAO_SILENT="${KAKAO_SILENT:-0}"
    # Korean input: wine talks XIM to the desktop session's own input method.
    -e XMODIFIERS="${XMODIFIERS:-@im=ibus}"
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw
    -v "$VOLUME":/root/.wine
    -v "$SHARE":/root/Downloads
)

# Notification sounds: hand over the desktop's PulseAudio socket. PipeWire
# serves the same socket through pipewire-pulse, so both work unchanged.
PULSE_SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/pulse/native"
if [[ -S "$PULSE_SOCKET" ]]; then
    ARGS+=(
        -e PULSE_SERVER="unix:$PULSE_SOCKET"
        -v "$PULSE_SOCKET":"$PULSE_SOCKET":rw
    )
    if [[ -f "$HOME/.config/pulse/cookie" ]]; then
        ARGS+=(-v "$HOME/.config/pulse/cookie":/root/.config/pulse/cookie:ro)
    fi
else
    echo "warning: no sound server socket at $PULSE_SOCKET; running muted" >&2
fi

exec docker run "${ARGS[@]}" "$IMAGE" "$@"
