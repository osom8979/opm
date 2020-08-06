FROM ubuntu:18.04
MAINTAINER zer0 <osom8979@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get install -y --no-install-recommends coturn
ENTRYPOINT [ "turnserver" ]
