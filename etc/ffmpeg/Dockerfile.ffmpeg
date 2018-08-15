FROM centos:7
MAINTAINER zer0 <osom8979@gmail.com>

RUN yum update -y
RUN yum install -y autoconf automake cmake freetype-devel gcc gcc-c++ git libtool make mercurial nasm pkgconfig zlib-devel

ENV WORKING /ffmpeg_sources
ENV PREFIX  /ffmpeg
ENV PROFILE /etc/profile.d/ffmpeg.sh

RUN echo "export PATH=$PATH:$PREFIX/bin" > $PROFILE
ENV PATH "$PATH:$PREFIX/bin"

RUN mkdir $WORKING

# INSTALL: Yasm
WORKDIR $WORKING
RUN git clone --depth 1 https://github.com/yasm/yasm.git
WORKDIR yasm
RUN autoreconf -fiv
RUN ./configure --prefix="$PREFIX"
RUN make
RUN make install
RUN make distclean

# INSTALL: libx264
WORKDIR $WORKING
#RUN git clone --depth 1 http://git.videolan.org/git/x264.git
RUN git clone http://git.videolan.org/git/x264.git
WORKDIR x264
RUN PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" ./configure --prefix="$PREFIX" --enable-static
RUN make
RUN make install
RUN make distclean

# INSTALL: libx265
WORKDIR $WORKING
RUN hg clone https://bitbucket.org/multicoreware/x265
WORKDIR x265/build/linux
RUN cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" -DENABLE_SHARED:bool=off ../../source
RUN make
RUN make install

# INSTALL: libfdk_aac
WORKDIR $WORKING
RUN git clone --depth 1 http://git.code.sf.net/p/opencore-amr/fdk-aac
WORKDIR fdk-aac
RUN autoreconf -fiv
RUN ./configure --prefix="$PREFIX" --disable-shared
RUN make
RUN make install
RUN make distclean

# INSTALL: libmp3lame
WORKDIR $WORKING
RUN curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
RUN tar xzvf lame-3.99.5.tar.gz
WORKDIR lame-3.99.5
RUN ./configure --prefix="$PREFIX" --disable-shared --enable-nasm
RUN make
RUN make install
RUN make distclean

# INSTALL: libopus
WORKDIR $WORKING
#RUN git clone --depth 1 git://git.opus-codec.org/opus.git
RUN git clone git://git.opus-codec.org/opus.git
WORKDIR opus
RUN autoreconf -fiv
RUN ./configure --prefix="$PREFIX" --disable-shared
RUN make
RUN make install
RUN make distclean

# INSTALL: libogg
WORKDIR $WORKING
RUN curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
RUN tar xzvf libogg-1.3.2.tar.gz
WORKDIR libogg-1.3.2
RUN ./configure --prefix="$PREFIX" --disable-shared
RUN make
RUN make install
RUN make distclean

# INSTALL: libvorbis
WORKDIR $WORKING
RUN curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
RUN tar xzvf libvorbis-1.3.4.tar.gz
WORKDIR libvorbis-1.3.4
RUN LDFLAGS="-L$PREFIX/lib" CPPFLAGS="-I$PREFIX/include" ./configure --prefix="$PREFIX" --with-ogg="$PREFIX" --disable-shared
RUN make
RUN make install
RUN make distclean

# INSTALL: libvpx
WORKDIR $WORKING
RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
WORKDIR libvpx
RUN ./configure --prefix="$PREFIX" --disable-examples --as=yasm
RUN make
RUN make install
RUN make clean

# INSTALL: ffmpeg
WORKDIR $WORKING
#RUN git clone --depth 1 http://source.ffmpeg.org/git/ffmpeg.git
RUN git clone http://source.ffmpeg.org/git/ffmpeg.git
WORKDIR ffmpeg
RUN PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" ./configure --prefix="$PREFIX" --extra-cflags="-I$PREFIX/include" --extra-ldflags="-L$PREFIX/lib" --pkg-config-flags="--static" --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265
RUN make
RUN make install
RUN make distclean
RUN hash -r

CMD ["/bin/bash"]

