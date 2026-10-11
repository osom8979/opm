#!/usr/bin/env bash
# AI Hub 데이터셋을 컨테이너 안의 aihubshell 로 현재 폴더(또는 $AIHUB_OUT)에 내려받는다.
# 완료된 파일은 .done/<filekey> 로 기록되므로, 다시 실행하면 남은 파일만 받는다.
#
#   aihub.run.sh -d 71939 <API_KEY>               전체 다운로드
#   aihub.run.sh -d 71939 --list                  파일 목록과 완료 여부 (키 불필요)
#   aihub.run.sh -d 71939 -m '^(TL|VL)_' <KEY>    라벨링 데이터만
#   aihub.run.sh --help                           전체 옵션
#
#   환경 변수:
#     AIHUB_IMAGE   실행할 이미지 태그      (기본: osom8979/aihub:latest)
#     AIHUB_OUT     내려받을 호스트 폴더    (기본: $PWD)
#     AIHUB_APIKEY  API 키 (인자 대신 넘길 때)

set -euo pipefail

IMAGE="${AIHUB_IMAGE:-osom8979/aihub:latest}"
OUT="${AIHUB_OUT:-$PWD}"

mkdir -p "$OUT"

ARGS=(
    --rm
    # 엔트리포인트(bash)가 PID 1 이면 Ctrl-C 나 docker stop 을 제대로 받지 못한다.
    --init
    # 받은 파일이 root 가 아니라 호출한 사용자 소유가 되도록 한다.
    --user "$(id -u):$(id -g)"
    -e AIHUB_APIKEY
    -v "$OUT":/data
)

# 터미널이 있을 때만 -it 를 붙인다. 백그라운드나 파이프로 실행해도 동작하도록.
if [[ -t 0 && -t 1 ]]; then
    ARGS+=(-it)
fi

docker run "${ARGS[@]}" "$IMAGE" "$@"
