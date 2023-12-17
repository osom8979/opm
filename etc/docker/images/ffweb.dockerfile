FROM jlesage/firefox:latest
MAINTAINER zer0 <osom8979@gmail.com>

ENV FIREFOX_ROOT=/usr/lib/firefox

ENV VDH_URL="https://github.com/mi-g/vdhcoapp/releases/download/v1.6.3/net.downloadhelper.coapp-1.6.3-1_amd64.tar.gz"
ENV VDH_OUT=/vdh.tar.gz
ENV VDH_DIST=/vdh

ENV VDH_EXT_URL="https://addons.mozilla.org/firefox/downloads/file/4157053/video_downloadhelper-8.0.0.6.xpi"
ENV VDH_EXT_OUT=/vdh.xpi

COPY ffweb.startapp.sh /startapp.sh

RUN chmod +x /startapp.sh && \
    add-pkg font-wqy-zenhei --repository https://dl-cdn.alpinelinux.org/alpine/v3.19/community/ && \
    apk add libc6-compat libstdc++ curl ca-certificates gcompat jq wqy-zenhei && \
    curl -f -L -o "$VDH_OUT" "$VDH_URL" && \
    curl -f -L -o "$VDH_EXT_OUT" "$VDH_EXT_URL" && \
    mkdir -p "$VDH_DIST" && \
    tar xf "$VDH_OUT" -C "$VDH_DIST" && \
    "$VDH_DIST/net.downloadhelper.coapp-1.6.3/bin/net.downloadhelper.coapp-linux-64" install --system

