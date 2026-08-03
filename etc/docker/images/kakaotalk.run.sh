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
GUEST_HOME=/home/kakao

: "${DISPLAY:?DISPLAY is not set; run this from an X11 desktop session}"

mkdir -p "$SHARE"

# Hand the container one display's X cookie rather than opening the server to
# every local process the way "xhost +local:" does -- that would let anything on
# this machine read our keystrokes. The address family is rewritten to the
# wildcard so the cookie still matches when presented from inside a container.
XAUTH=$(mktemp /tmp/.kakaotalk.xauth.XXXXXXXX)
trap 'rm -f "$XAUTH"' EXIT
if ! xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge -; then
    echo "error: no X cookie for $DISPLAY; cannot authorize the container" >&2
    exit 1
fi
chmod 644 "$XAUTH"

ARGS=(
    --rm -it
    --name kakaotalk
    -e DISPLAY="$DISPLAY"
    -e XAUTHORITY="$XAUTH"
    -e KAKAO_SILENT="${KAKAO_SILENT:-0}"
    # Run as the invoking user so received files stay editable on the host.
    -e KAKAO_UID="$(id -u)"
    -e KAKAO_GID="$(id -g)"
    # Korean input: wine talks XIM to the desktop session's own input method.
    -e XMODIFIERS="${XMODIFIERS:-@im=ibus}"
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw
    -v "$XAUTH":"$XAUTH":ro
    -v "$VOLUME":"$GUEST_HOME/.wine"
    -v "$SHARE":"$GUEST_HOME/Downloads"
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
        ARGS+=(
            -v "$HOME/.config/pulse/cookie":"$GUEST_HOME/.config/pulse/cookie":ro
        )
    fi
else
    echo "warning: no sound server socket at $PULSE_SOCKET; running muted" >&2
fi

docker run "${ARGS[@]}" "$IMAGE" "$@"
