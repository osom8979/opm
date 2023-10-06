FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND noninteractive
ENV OPENCV_VERSION 3.4.16

RUN apt update -qq && \
    apt install -y cmake g++ wget unzip ninja-build \
        python3-dev python3-numpy \
        libavcodec-dev libavformat-dev libswscale-dev \
        libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev \
        libgtk-3-dev \
        libpng-dev libjpeg-dev libopenexr-dev libtiff-dev libwebp-dev && \
    mkdir /opencv /opencv-build && \
    cd /opencv-build && \
    wget -O opencv.zip https://github.com/opencv/opencv/archive/refs/tags/${OPENCV_VERSION}.zip && \
    unzip opencv.zip && \
    mkdir build && \
    cd build && \
    cmake -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/opencv \
        -DBUILD_TESTS=OFF \
        -DBUILD_PERF_TESTS=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_opencv_apps=ON \
        ../opencv-${OPENCV_VERSION} && \
    cmake --build . -j 8 && \
    cmake --build . --target install

# --[[ NEXT STAGE
FROM ubuntu:20.04
COPY --from=builder /opencv /opencv
WORKDIR /opencv/bin

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -qq && \
    apt install -y cmake g++ wget unzip ninja-build \
        python3-dev python3-numpy \
        libavcodec-dev libavformat-dev libswscale-dev \
        libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev \
        libgtk-3-dev \
        libpng-dev libjpeg-dev libopenexr-dev libtiff-dev libwebp-dev

