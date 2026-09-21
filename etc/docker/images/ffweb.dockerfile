FROM jlesage/firefox:latest
LABEL maintainer="zer0 <osom8979@gmail.com>"

ENV FIREFOX_ROOT=/usr/lib/firefox

ENV FFCAP_ENABLE=1
ENV FFCAP_DIR=/config/captures
ENV FFCAP_FULL_FETCH=1
ENV FFCAP_PORT=8080

COPY ffweb.startapp.sh /startapp.sh
COPY ffweb.capture.py /ffcap.py

RUN chmod +x /startapp.sh && \
    add-pkg font-wqy-zenhei --repository https://dl-cdn.alpinelinux.org/alpine/v3.19/community/ && \
    apk add libc6-compat libstdc++ curl ca-certificates gcompat wqy-zenhei mitmproxy && \
    mkdir -p "$FIREFOX_ROOT/distribution" && \
    echo '{"policies":{"Certificates":{"Install":["/config/.mitmproxy/mitmproxy-ca-cert.pem"]}}}' \
        > "$FIREFOX_ROOT/distribution/policies.json"
