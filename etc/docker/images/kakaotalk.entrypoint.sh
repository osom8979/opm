#!/usr/bin/env bash
# Bootstrap the wine prefix, install KakaoTalk on first run, then launch it on
# the X11 display provided by the host ($DISPLAY).

set -euo pipefail

: "${KAKAO_USER:=kakao}"
: "${KAKAO_HOME:=/home/kakao}"
: "${WINEPREFIX:=$KAKAO_HOME/.wine}"
: "${WINEARCH:=win64}"
: "${KAKAO_SETUP_PATH:=/opt/kakaotalk/KakaoTalk_Setup.exe}"
: "${KAKAO_SHARE_DIR:=$KAKAO_HOME/KakaoTalk}"
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

# Point a Windows folder inside the prefix at the shared directory. Whatever
# the folder already holds is carried across first: a prefix that predates this
# wiring can have real files in it, and they would otherwise stay stranded in
# the wine volume where the host cannot reach them. mv -n means a name that
# already exists on the host side wins, so nothing is overwritten.
link_into_share() {
    local dir=$1

    if [[ ! -L "$dir" && -d "$dir" ]]; then
        find "$dir" -mindepth 1 -maxdepth 1 \
            -exec mv -n -t "$KAKAO_SHARE_DIR" {} +
        if ! rmdir "$dir" 2> /dev/null; then
            echo "[kakaotalk] WARN: could not empty $dir; leaving it." >&2
            echo "[kakaotalk] The shared directory is still available as drive D:." >&2
            return
        fi
    fi

    mkdir -p "$(dirname "$dir")"
    ln -sfn "$KAKAO_SHARE_DIR" "$dir"
}

# Wire the host's shared directory into the prefix so files can cross the
# container boundary in both directions.
if [[ -d "$KAKAO_SHARE_DIR" ]]; then
    # Always reachable as drive D: from any file dialog.
    ln -sfn "$KAKAO_SHARE_DIR" "$WINEPREFIX/dosdevices/d:"

    WIN_USER_DIR="$WINEPREFIX/drive_c/users/$KAKAO_USER"

    # The one that matters: KakaoTalk writes every received file into this
    # fixed path under Documents and offers no setting to move it, so that
    # folder -- not "Downloads", which the app never touches -- is what has to
    # become the share for received files to reach the host at all.
    link_into_share "$WIN_USER_DIR/Documents/카카오톡 받은 파일"

    # And "Downloads" as well, so the share is where file dialogs start.
    link_into_share "$WIN_USER_DIR/Downloads"
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

# Not exec'd, and not waited on alone: an update makes KakaoTalk spawn
# KakaoUpdate.exe and then quit, leaving the updater to patch the installation
# and start the new build. Tying the container's lifetime to KakaoTalk.exe would
# tear the whole prefix down at exactly that moment and kill the updater
# mid-patch -- which is why an update could download forever and never apply.
# Wait for the prefix to go quiet instead, so every successor process outlives
# the one that started it.
wine "$KAKAO_EXE" "$@" &
WINE_PID=$!

# Backgrounding wine also means "docker stop" now reaches a shell rather than
# the app, so pass the shutdown on: bash runs traps while waiting, not while a
# foreground command holds the terminal.
trap 'wineserver -k' INT TERM

status=0
wait "$WINE_PID" || status=$?
trap - INT TERM

wineserver -w
exit "$status"
