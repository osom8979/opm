FROM ubuntu:24.04
LABEL maintainer="zer0 <osom8979@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=ko_KR.UTF-8
ENV LANGUAGE=ko_KR:ko
ENV LC_ALL=ko_KR.UTF-8
ENV TZ=Asia/Seoul

# KakaoTalk runs as this unprivileged account rather than as root. The
# entrypoint re-maps it onto the host's uid at startup, so files written into
# the shared directory stay owned -- and editable -- by the host user.
ENV KAKAO_USER=kakao
ENV KAKAO_HOME=/home/kakao
ENV HOME=/home/kakao

# Wine runs against this prefix. Mount it as a volume at runtime so the
# KakaoTalk installation and login session survive container restarts.
ENV WINEARCH=win64
ENV WINEPREFIX=/home/kakao/.wine
ENV WINEDEBUG=-all
# Suppress the Mono/Gecko installation dialogs during prefix bootstrap.
ENV WINEDLLOVERRIDES="mscoree,mshtml="

# Korean input. Wine speaks XIM over the shared X11 socket, so it can drive the
# desktop session's own ibus without an input method daemon in the container.
ENV XMODIFIERS=@im=ibus
ENV GTK_IM_MODULE=ibus
ENV QT_IM_MODULE=ibus

# Bind-mounted from the host at runtime; the directory KakaoTalk reads sent
# files from and writes received ones to.
ENV KAKAO_SHARE_DIR=/home/kakao/Downloads

ENV KAKAO_SETUP_URL="https://app-pc.kakaocdn.net/talk/win32/x64/KakaoTalk_Setup.exe"
ENV KAKAO_SETUP_PATH=/opt/kakaotalk/KakaoTalk_Setup.exe

# Base runtime dependencies (Korean fonts, locale, X11 helpers, wine helpers).
# xvfb backs the headless bootstrap path in the entrypoint; libpulse carries
# notification sounds out to the host sound server.
RUN dpkg --add-architecture i386 && \
    apt-get -qq update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl \
        locales tzdata \
        xvfb xauth x11-utils \
        cabextract winbind \
        libpulse0 libpulse0:i386 \
        fonts-nanum fonts-nanum-coding fonts-nanum-extra && \
    rm -rf /var/lib/apt/lists/*

# The account KakaoTalk runs under. Ubuntu 24.04 ships a stock "ubuntu" user on
# uid 1000, which is exactly the uid most desktop hosts hand out, so drop it to
# leave that number free for the entrypoint to claim. Directories that back a
# mount are pre-created and owned here, since docker copies their ownership onto
# a fresh volume.
RUN { userdel -r ubuntu || true; } 2> /dev/null && \
    useradd --create-home --uid 1000 --user-group --shell /bin/bash kakao && \
    mkdir -p /home/kakao/.wine /home/kakao/Downloads /home/kakao/.config/pulse && \
    chown -R kakao:kakao /home/kakao

# Korean locale and Asia/Seoul timezone.
RUN sed -i 's/^# *\(ko_KR.UTF-8\)/\1/' /etc/locale.gen && \
    locale-gen ko_KR.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    echo Asia/Seoul > /etc/timezone

# WineHQ stable branch (official repository).
RUN mkdir -pm755 /etc/apt/keyrings && \
    curl -fSL -o /etc/apt/keyrings/winehq-archive.key \
        https://dl.winehq.org/wine-builds/winehq.key && \
    curl -fSL -o /etc/apt/sources.list.d/winehq-noble.sources \
        https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources && \
    apt-get -qq update && \
    apt-get install -y --install-recommends winehq-stable && \
    rm -rf /var/lib/apt/lists/*

# Latest winetricks (handy for troubleshooting fonts/DLLs).
RUN curl -fSL -o /usr/local/bin/winetricks \
        https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/local/bin/winetricks

# Bake the KakaoTalk installer into the image so the container can install
# offline on first run. Rebuilding the image re-fetches the latest installer.
RUN mkdir -p /opt/kakaotalk && \
    curl -fSL -o "$KAKAO_SETUP_PATH" "$KAKAO_SETUP_URL"

COPY kakaotalk.entrypoint.sh /usr/local/bin/kakaotalk-entrypoint
RUN chmod +x /usr/local/bin/kakaotalk-entrypoint

ENTRYPOINT ["/usr/local/bin/kakaotalk-entrypoint"]
