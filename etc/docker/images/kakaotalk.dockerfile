FROM ubuntu:24.04
LABEL maintainer="zer0 <osom8979@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=ko_KR.UTF-8
ENV LANGUAGE=ko_KR:ko
ENV LC_ALL=ko_KR.UTF-8
ENV TZ=Asia/Seoul

# Wine runs against this prefix. Mount it as a volume at runtime so the
# KakaoTalk installation and login session survive container restarts.
ENV WINEARCH=win64
ENV WINEPREFIX=/root/.wine
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
ENV KAKAO_SHARE_DIR=/root/Downloads

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
