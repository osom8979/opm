FROM ubuntu:24.04
LABEL maintainer="zer0 <osom8979@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=Asia/Seoul

# aihubshell 안에서 부르는 curl 도 $CURL_HOME/.curlrc 를 읽는다. 서버가 응답 없이
# 멈춘 연결을 붙잡고 있는 일이 있어서, 300초 동안 1KB/s 미만이면 끊고 엔트리포인트의
# 재시도로 넘긴다. 정상 전송 중에 멈추는 구간은 길어야 수십 초였다.
ENV CURL_HOME=/etc/aihub

# unzip 은 받은 zip 의 CRC 검사용이다.
RUN apt-get -qq update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl unzip tzdata && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p "$CURL_HOME" && \
    printf 'speed-limit = 1024\nspeed-time = 300\n' > "$CURL_HOME/.curlrc"

# 이미지를 다시 빌드하면 최신 aihubshell 을 다시 받는다.
RUN curl -fSL -o /usr/local/bin/aihubshell https://api.aihub.or.kr/api/aihubshell.do && \
    chmod +x /usr/local/bin/aihubshell

COPY aihub.entrypoint.sh /usr/local/bin/aihub-entrypoint
RUN chmod +x /usr/local/bin/aihub-entrypoint

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/aihub-entrypoint"]
