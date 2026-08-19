# =============================================================================
# Coder Workspace Image for NVIDIA DGX Spark (GB10 / Grace Blackwell / arm64)
#
#   Ubuntu 24.04 (noble) + CUDA 13.0 + cuDNN + Python 3.12
#   + PyTorch(cu130) + gh + uv + ffmpeg
#
# GB10 은 compute capability 12.1(sm_121) 이다. cu128 휠에 포함된 ptxas 는
# sm_121 을 인식하지 못하므로 반드시 cu130 휠을 사용해야 한다.
# (sm_120 과 sm_121 은 바이너리 호환이므로 cu130 공식 휠로 동작한다.)
#
# Build (DGX Spark 위에서 직접 빌드하는 것을 권장):
#   docker build -f dgx-spark.dockerfile -t coder-dgx-spark:cuda13 .
#
# Build (x86 호스트에서 크로스 빌드: qemu 필요, 매우 느림):
#   docker run --privileged --rm tonistiigi/binfmt --install arm64
#   docker buildx build --platform linux/arm64 \
#       -f dgx-spark.dockerfile -t coder-dgx-spark:cuda13 --load .
# =============================================================================

ARG UV_VERSION=0.12.5
ARG CUDA_IMAGE_TAG=13.0.3-cudnn-devel-ubuntu24.04

# uv 는 공식 배포 이미지에서 정적 바이너리만 복사한다. (multi-arch)
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM nvidia/cuda:${CUDA_IMAGE_TAG}

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Asia/Seoul
ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=1000
# GH_VERSION 을 비워두면 저장소의 최신 버전을 설치한다. (예: GH_VERSION=2.97.0 으로 고정 가능)
ARG GH_VERSION=

# -----------------------------------------------------------------------------
# 1. 기본 패키지
#    - ffmpeg: torchcodec 의 오디오/비디오 디코딩 백엔드 (noble 은 6.1.x)
#    - python3.12*: noble 의 시스템 파이썬이 곧 3.12 이다
#    - build-essential/cmake/ninja: custom CUDA extension 빌드용 (nvcc 는 devel 이미지에 포함)
#    - libgl1/libglib2.0-0t64: opencv/torchvision 런타임 의존성
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash \
        bash-completion \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        file \
        ffmpeg \
        git \
        git-lfs \
        gnupg \
        htop \
        iproute2 \
        iputils-ping \
        jq \
        less \
        libgl1 \
        libglib2.0-0t64 \
        locales \
        man-db \
        nano \
        ninja-build \
        nvtop \
        openssh-client \
        pkg-config \
        procps \
        psmisc \
        python3.12 \
        python3.12-dev \
        python3.12-venv \
        rsync \
        sudo \
        tmux \
        tree \
        tzdata \
        unzip \
        vim \
        wget \
        zip \
        zstd \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# 2. 로케일 / 타임존
# -----------------------------------------------------------------------------
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' \
           -e 's/# ko_KR.UTF-8 UTF-8/ko_KR.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime \
    && echo "${TZ}" > /etc/timezone

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=${TZ}

# -----------------------------------------------------------------------------
# 3. GitHub CLI (arm64 공식 apt 저장소)
# -----------------------------------------------------------------------------
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh${GH_VERSION:+=${GH_VERSION}} \
    && rm -rf /var/lib/apt/lists/* \
    && gh --version

# -----------------------------------------------------------------------------
# 4. uv
# -----------------------------------------------------------------------------
COPY --from=uv /uv /uvx /usr/local/bin/

# -----------------------------------------------------------------------------
# 5. coder 사용자
#    noble 이미지에는 UID 1000 인 `ubuntu` 계정이 이미 존재하므로 제거 후 생성한다.
#    Coder 템플릿이 /home/coder 에 docker volume 을 마운트하는데, 볼륨이 처음
#    생성될 때 이미지의 해당 경로 소유권이 그대로 복사되므로 UID 를 맞춰야 한다.
# -----------------------------------------------------------------------------
RUN if getent passwd ${USER_UID} >/dev/null; then \
        userdel -r "$(getent passwd ${USER_UID} | cut -d: -f1)" 2>/dev/null || true; \
    fi \
    && if getent group ${USER_GID} >/dev/null; then \
        groupdel "$(getent group ${USER_GID} | cut -d: -f1)" 2>/dev/null || true; \
    fi \
    && groupadd -g ${USER_GID} ${USERNAME} \
    && useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && git lfs install --system

# -----------------------------------------------------------------------------
# 6. Python 3.12 가상환경 + PyTorch (cu130)
#
#    venv 를 /home 이 아닌 /opt 에 두는 이유:
#    Coder 워크스페이스는 /home/coder 를 영속 볼륨으로 마운트하므로, 홈에 설치한
#    내용은 이미지를 새로 빌드해도 기존 워크스페이스에 반영되지 않는다.
# -----------------------------------------------------------------------------
ENV VIRTUAL_ENV=/opt/venv
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${VIRTUAL_ENV}/bin:${CUDA_HOME}/bin:/usr/local/bin:${PATH}

# 2026-08 기준 cu130 인덱스의 aarch64/cp312 최신 조합.
#   torch 2.13.0 <-> torchvision 0.28.0 <-> torchcodec 0.16.0 (torch>=2.11 요구)
# NOTE: torchaudio 는 aarch64 + cu130 휠이 2.9.1 에서 멈춰 있어 의도적으로 제외했다.
#       (설치하면 torch 가 2.9 로 다운그레이드된다. 오디오/비디오 디코딩은 torchcodec 사용)
ARG TORCH_INDEX_URL=https://download.pytorch.org/whl/cu130
ARG TORCH_VERSION=2.13.0
ARG TORCHVISION_VERSION=0.28.0
ARG TORCHCODEC_VERSION=0.16.0

RUN python3.12 -m venv "${VIRTUAL_ENV}" \
    && uv pip install --no-cache --upgrade pip setuptools wheel \
    && uv pip install --no-cache \
        --index-url "${TORCH_INDEX_URL}" \
        "torch==${TORCH_VERSION}" \
        "torchvision==${TORCHVISION_VERSION}" \
        "torchcodec==${TORCHCODEC_VERSION}" \
    && python -c "import torch, torchvision, torchcodec; print('torch', torch.__version__, '| cuda', torch.version.cuda, '| tv', torchvision.__version__)" \
    && chown -R ${USER_UID}:${USER_GID} "${VIRTUAL_ENV}"

# 필요하면 여기에 상시 사용하는 패키지를 추가한다.
# RUN uv pip install --no-cache numpy pandas matplotlib jupyterlab transformers datasets accelerate

# -----------------------------------------------------------------------------
# 7. 셸 환경
#    coder agent 가 띄우는 셸이 login/non-login 어느 쪽이든 PATH 가 잡히도록
#    profile.d 와 bash.bashrc 양쪽에 심는다.
# -----------------------------------------------------------------------------
RUN printf '%s\n' \
        'export CUDA_HOME=/usr/local/cuda' \
        'export VIRTUAL_ENV=/opt/venv' \
        'case ":${PATH}:" in' \
        '  *":/opt/venv/bin:"*) ;;' \
        '  *) export PATH="/opt/venv/bin:${CUDA_HOME}/bin:${PATH}" ;;' \
        'esac' \
        > /etc/profile.d/10-coder-cuda.sh \
    && chmod 0644 /etc/profile.d/10-coder-cuda.sh \
    && echo '. /etc/profile.d/10-coder-cuda.sh' >> /etc/bash.bashrc

# main.tf 의 startup_script 가 최초 기동 시 `cp -rT /etc/skel ~` 를 수행한다.
RUN printf '%s\n' \
        '' \
        '# --- DGX Spark workspace ---' \
        'export EDITOR=vim' \
        'alias ll="ls -alF"' \
        'alias gs="git status"' \
        >> /etc/skel/.bashrc

# -----------------------------------------------------------------------------
# 8. 런타임 환경변수
#    - video capability: ffmpeg/torchcodec 의 NVDEC 하드웨어 디코딩용
#    - TORCH_CUDA_ARCH_LIST: GB10(sm_121) 대상 소스 빌드 시 사용
# -----------------------------------------------------------------------------
ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility,video \
    TORCH_CUDA_ARCH_LIST=12.1 \
    UV_LINK_MODE=copy \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONUNBUFFERED=1

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Coder 는 entrypoint 를 agent init script 로 덮어쓴다. 아래는 로컬 검증용 기본값.
CMD ["/bin/bash"]
