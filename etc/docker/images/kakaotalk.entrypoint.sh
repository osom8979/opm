#!/usr/bin/env bash
# Bootstrap the wine prefix, install KakaoTalk on first run, then launch it on
# the X11 display provided by the host ($DISPLAY).

set -euo pipefail

: "${KAKAO_USER:=kakao}"
: "${KAKAO_HOME:=/home/kakao}"
: "${WINEPREFIX:=$KAKAO_HOME/.wine}"
: "${WINEARCH:=win64}"
: "${KAKAO_SETUP_PATH:=/opt/kakaotalk/KakaoTalk_Setup.exe}"
: "${KAKAO_SHARE_DIR:=$KAKAO_HOME/Downloads}"
export WINEPREFIX WINEARCH HOME="$KAKAO_HOME"

# Started as root: line the container account up with the host's uid/gid before
# doing anything else, so every file KakaoTalk later writes into the shared
# directory belongs to the host user instead of root. Then drop privileges and
# re-enter this same script as that account.
if [[ "$(id -u)" -eq 0 ]]; then
    uid="${KAKAO_UID:-$(id -u "$KAKAO_USER")}"
    gid="${KAKAO_GID:-$(id -g "$KAKAO_USER")}"

    [[ "$(id -g "$KAKAO_USER")" == "$gid" ]] || groupmod -o -g "$gid" "$KAKAO_USER"
    [[ "$(id -u "$KAKAO_USER")" == "$uid" ]] || usermod -o -u "$uid" "$KAKAO_USER"

    # Re-own the home only when it actually changed hands -- the wine prefix is
    # thousands of files. The shared directory is a host bind mount, so prune it:
    # its ownership belongs to the host and must not be rewritten from in here.
    if [[ "$(stat -c %u "$KAKAO_HOME")" != "$uid" ]]; then
        echo "[kakaotalk] Adopting uid $uid:$gid for $KAKAO_HOME ..."
        find "$KAKAO_HOME" -path "$KAKAO_SHARE_DIR" -prune -o \
            -exec chown -h "$uid:$gid" {} +
    fi

    exec setpriv --reuid="$uid" --regid="$gid" --init-groups "$0" "$@"
fi

# Korean input: wine connects to whichever XIM server owns the display, which
# is the host session's ibus-x11 when /tmp/.X11-unix is shared.
export XMODIFIERS="${XMODIFIERS:-@im=ibus}"
export GTK_IM_MODULE="${GTK_IM_MODULE:-ibus}"
export QT_IM_MODULE="${QT_IM_MODULE:-ibus}"

KAKAO_EXE="$WINEPREFIX/drive_c/Program Files/Kakao/KakaoTalk/KakaoTalk.exe"

# Both the prefix bootstrap and the installer need an X server. Without a host
# display, fall back to a throwaway virtual one so the image can still be primed
# headlessly -- the GUI itself, of course, has nowhere to go.
if [[ -z "${DISPLAY:-}" ]]; then
    echo "[kakaotalk] WARN: DISPLAY is empty; starting a virtual X server." >&2
    echo "[kakaotalk] Nothing will be visible. Pass -e DISPLAY and mount" >&2
    echo "[kakaotalk] /tmp/.X11-unix to see the GUI (see kakaotalk.run.sh)." >&2
    Xvfb :99 -screen 0 1280x1024x24 &
    export DISPLAY=:99
    until xdpyinfo -display :99 &> /dev/null; do
        sleep 0.2
    done
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

# Wire the host's shared directory into the prefix so files can cross the
# container boundary in both directions.
if [[ -d "$KAKAO_SHARE_DIR" ]]; then
    # Always reachable as drive D: from any file dialog.
    ln -sfn "$KAKAO_SHARE_DIR" "$WINEPREFIX/dosdevices/d:"

    # Make it the Windows "Downloads" folder too, so received files land there
    # by default. Only replace the directory wine created if it is still empty
    # -- never discard files someone already has in the prefix.
    WIN_DOWNLOADS="$WINEPREFIX/drive_c/users/$KAKAO_USER/Downloads"
    if [[ ! -L "$WIN_DOWNLOADS" ]]; then
        if rmdir "$WIN_DOWNLOADS" 2> /dev/null; then
            ln -sfn "$KAKAO_SHARE_DIR" "$WIN_DOWNLOADS"
        else
            echo "[kakaotalk] WARN: $WIN_DOWNLOADS is not empty; leaving it." >&2
            echo "[kakaotalk] The shared directory is still available as drive D:." >&2
        fi
    fi
else
    echo "[kakaotalk] WARN: $KAKAO_SHARE_DIR is not mounted; no shared folder." >&2
fi

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
