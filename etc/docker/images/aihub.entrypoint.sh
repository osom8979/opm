#!/usr/bin/env bash
# aihubshell 로 AI Hub 데이터셋을 파일(filekey) 단위로 내려받는다.
# - 파일마다 별도 작업 폴더에서 받아 검증한 뒤 출력 폴더로 옮긴다.
# - 완료된 파일은 .done/<filekey> 로 기록하므로, 다시 실행하면 남은 파일만 받는다.
# - 서버가 전송 도중 연결을 끊는 일이 잦아서, 실패한 파일은 정해진 횟수만큼 다시 받는다.

set -euo pipefail

DATASET_KEY="${DATASET_KEY:-}"
OUT_DIR="${OUT_DIR:-/data}"
AIHUBSHELL="${AIHUBSHELL:-aihubshell}"
RETRIES="${RETRIES:-3}"
RETRY_WAIT="${RETRY_WAIT:-60}"

usage() {
    cat <<EOF
사용법: opm-aihub -d <DATASET_KEY> [옵션] <AIHUB_API_KEY>

AI Hub 데이터셋을 aihubshell 로 내려받는다.
API 키는 위치 인자 또는 환경 변수 AIHUB_APIKEY 로 넘긴다.

옵션:
  -d, --dataset KEY      데이터셋 키 (필수, 예: 71939)
  -l, --list             파일 목록과 완료 여부만 출력하고 종료 (API 키 불필요)
  -f, --filekeys K1,K2   지정한 filekey 만 받기
  -m, --match REGEX      파일 이름이 REGEX(grep -E)에 맞는 것만 받기 (예: '^(TL|VL)_')
  -r, --retries N        파일당 최대 시도 횟수 (기본: ${RETRIES})
  -o, --output DIR       컨테이너 안의 출력 폴더 (기본: ${OUT_DIR})
  -h, --help             도움말
EOF
}

API_KEY=""
FILEKEYS=""
MATCH=""
LIST_ONLY=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        -l|--list) LIST_ONLY=1 ;;
        -f|--filekeys) FILEKEYS="${2:?--filekeys 값이 필요합니다}"; shift ;;
        -m|--match) MATCH="${2:?--match 값이 필요합니다}"; shift ;;
        -r|--retries) RETRIES="${2:?--retries 값이 필요합니다}"; shift ;;
        -d|--dataset) DATASET_KEY="${2:?--dataset 값이 필요합니다}"; shift ;;
        -o|--output) OUT_DIR="${2:?--output 값이 필요합니다}"; shift ;;
        -*) echo "알 수 없는 옵션: $1" >&2; usage >&2; exit 2 ;;
        *)
            if [[ -n "$API_KEY" ]]; then
                echo "API 키 인자가 두 번 이상 주어졌습니다." >&2; exit 2
            fi
            API_KEY="$1"
            ;;
    esac
    shift
done

API_KEY="${API_KEY:-${AIHUB_APIKEY:-}}"
FILEKEYS="${FILEKEYS// /}"

if [[ ! $DATASET_KEY =~ ^[0-9]+$ ]]; then
    echo "데이터셋 키(-d)가 필요합니다." >&2
    usage >&2
    exit 2
fi
if [[ ! $RETRIES =~ ^[1-9][0-9]*$ ]]; then
    echo "--retries 는 1 이상의 정수여야 합니다." >&2
    exit 2
fi

log() { printf '[%(%F %T)T] %s\n' -1 "$*"; }

trap 'log "중단되었습니다."; exit 130' INT TERM

mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"
DONE_DIR="$OUT_DIR/.done"

# 파일 트리에서 "filekey<TAB>파일명<TAB>크기" 를 뽑는다.
#   예: │  ├─TS_RTAL_결함_1. 균열.zip | 5 MB | 533307
TREE_FILE="$OUT_DIR/filetree_${DATASET_KEY}.txt"
"$AIHUBSHELL" -mode l -datasetkey "$DATASET_KEY" | tr -d '\r' > "$TREE_FILE"
mapfile -t FILES < <(sed -nE 's/^.*─(.+) \| ([^|]+) \| ([0-9]+)[[:space:]]*$/\3\t\1\t\2/p' "$TREE_FILE")

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "데이터셋 ${DATASET_KEY} 의 파일 목록을 가져오지 못했습니다. ${TREE_FILE} 를 확인하세요." >&2
    exit 1
fi

# 필터 적용
SELECTED=()
for row in "${FILES[@]}"; do
    IFS=$'\t' read -r key name _size <<<"$row"
    if [[ -n "$FILEKEYS" && ",${FILEKEYS}," != *",${key},"* ]]; then
        continue
    fi
    if [[ -n "$MATCH" ]] && ! grep -qE -- "$MATCH" <<<"$name"; then
        continue
    fi
    SELECTED+=("$row")
done

if [[ $LIST_ONLY -eq 1 ]]; then
    n_done=0
    for row in "${SELECTED[@]}"; do
        IFS=$'\t' read -r key name size <<<"$row"
        status="-"
        if [[ -e "$DONE_DIR/$key" ]]; then
            status="완료"
            n_done=$((n_done + 1))
        fi
        printf '%-8s %8s  %-4s  %s\n' "$key" "$size" "$status" "$name"
    done
    echo "총 ${#SELECTED[@]}개 파일, 완료 ${n_done}개, 남음 $(( ${#SELECTED[@]} - n_done ))개 (전체 트리: ${TREE_FILE})"
    exit 0
fi

if [[ -z "$API_KEY" ]]; then
    echo "API 키가 없습니다. 인자 또는 AIHUB_APIKEY 환경 변수로 넘겨 주세요." >&2
    usage >&2
    exit 2
fi

if [[ ${#SELECTED[@]} -eq 0 ]]; then
    echo "조건에 맞는 파일이 없습니다." >&2
    exit 1
fi

# 작업 폴더는 하드링크로 옮길 수 있도록 출력 폴더와 같은 파일시스템에 둔다.
WORK_ROOT="$OUT_DIR/.work"
LOG_DIR="$OUT_DIR/.logs"
mkdir -p "$WORK_ROOT" "$DONE_DIR" "$LOG_DIR"
# 중간에 끝나도 비어 있는 작업 폴더는 남기지 않는다. (덜 받은 파일은 다음 실행이 지운다.)
trap 'rmdir "$WORK_ROOT" 2>/dev/null || true' EXIT

# aihubshell 0.6 의 병합 단계는 `for prefix in $(ls ...)` 로 이름을 단어 단위로 쪼개서,
# 이름에 공백이 있는 파일은 병합하지 못하고 조각 이름의 빈 파일만 만든다.
# (지금은 서버가 tar 안의 공백을 '_' 로 바꿔 보내지만, 대비해서) 남은 .part 파일을 직접 병합한다.
# 진행 상황은 stderr, 실패 사유는 stdout 으로 출력한다.
merge_leftover_parts() {
    local work="$1" part prefix dir n offset word
    local -a nums words
    local -A prefixes=()

    while IFS= read -r -d '' part; do
        prefixes["${part%.part*}"]=1
    done < <(find "$work" -type f -regex '.*\.part[0-9]+' -print0)

    for prefix in "${!prefixes[@]}"; do
        dir="$(dirname "$prefix")"
        mapfile -t nums < <(
            for part in "$prefix".part*; do
                n="${part##*.part}"
                [[ $n =~ ^[0-9]+$ ]] && echo "$n"
            done | sort -n
        )

        # part 접미사는 바이트 오프셋이다 (.part0, .part1073741824, ...). 빈 구간이 없는지 확인한다.
        offset=0
        for n in "${nums[@]}"; do
            if [[ $n -ne $offset ]]; then
                echo "part 파일이 빠져 있습니다: ${prefix#"$work"/}.part$offset"
                return 1
            fi
            offset=$((offset + $(stat -c %s "$prefix.part$n")))
        done

        log "  병합: ${prefix#"$work"/} (part ${#nums[@]}개)" >&2
        : > "$prefix"
        # 디스크 사용량을 줄이려고 붙인 part 는 바로 지운다.
        for n in "${nums[@]}"; do
            if ! cat "$prefix.part$n" >> "$prefix"; then
                echo "병합 중 오류: ${prefix#"$work"/}"
                return 1
            fi
            rm -f "$prefix.part$n"
        done

        read -ra words <<<"$(basename "$prefix")"
        if [[ ${#words[@]} -gt 1 ]]; then
            for word in "${words[@]}"; do
                if [[ -f "$dir/$word" && ! -s "$dir/$word" ]]; then
                    rm -f "$dir/$word"
                fi
            done
        fi
    done
}

# 작업 폴더 결과 검증: 남은 tar/part 파일이 없고, zip 은 CRC 검사를 통과해야 한다.
verify_work() {
    local work="$1" f rc

    if [[ -e "$work/download.tar" ]]; then
        echo "download.tar 가 남아 있습니다 (다운로드 또는 해제 실패)."
        return 1
    fi
    if [[ -n "$(find "$work" -type f -name '*.part[0-9]*' -print -quit)" ]]; then
        echo "병합되지 않은 .part 파일이 남아 있습니다."
        return 1
    fi
    if [[ -z "$(find "$work" -type f -print -quit)" ]]; then
        echo "받은 파일이 없습니다."
        return 1
    fi
    while IFS= read -r -d '' f; do
        log "  zip 검사: ${f#"$work"/}" >&2
        rc=0
        unzip -tqq "$f" >/dev/null 2>&1 || rc=$?
        # unzip 종료 코드 1 은 경고(파일명 인코딩 등)일 뿐 데이터는 정상이다.
        if [[ $rc -gt 1 ]]; then
            echo "zip 검사 실패 (unzip 종료 코드 $rc): ${f#"$work"/}"
            return 1
        fi
    done < <(find "$work" -type f -name '*.zip' -print0)
}

total=${#SELECTED[@]}
idx=0
n_ok=0
n_skip=0
failed=()

for row in "${SELECTED[@]}"; do
    idx=$((idx + 1))
    IFS=$'\t' read -r key name size <<<"$row"
    tag="[$idx/$total] $key $name ($size)"

    if [[ -e "$DONE_DIR/$key" ]]; then
        log "$tag : 이미 완료됨, 건너뜀"
        n_skip=$((n_skip + 1))
        continue
    fi

    work="$WORK_ROOT/$key"
    logfile="$LOG_DIR/$key.log"
    ok=0

    for ((attempt = 1; attempt <= RETRIES; attempt++)); do
        log "$tag : 다운로드 시작 (시도 $attempt/$RETRIES)"
        rm -rf "$work"
        mkdir -p "$work"

        # aihubshell 의 종료 코드는 실패해도 0 이라 신뢰할 수 없으므로 결과물로 판단한다.
        # 로그에는 마지막 시도만 남는다.
        (
            cd "$work"
            "$AIHUBSHELL" -mode d -datasetkey "$DATASET_KEY" -filekey "$key" -aihubapikey "$API_KEY"
        ) 2>&1 | tee "$logfile" || true

        if reason="$(merge_leftover_parts "$work" && verify_work "$work")"; then
            cp -al --remove-destination "$work/." "$OUT_DIR/"
            rm -rf "$work"
            date '+%F %T' > "$DONE_DIR/$key"
            log "$tag : 완료"
            ok=1
            break
        fi

        rm -rf "$work"
        curl_err="$(tr '\r' '\n' < "$logfile" | grep -oE 'curl: \([0-9]+\).*' | tail -n 1 || true)"
        log "$tag : 실패 - $reason${curl_err:+ [$curl_err]} (로그: $logfile)"

        # 키가 틀렸거나 데이터 이용 신청이 승인되지 않았으면 나머지도 모두 실패하므로 멈춘다.
        if grep -q '인증실패' "$logfile"; then
            log "인증에 실패했습니다. API 키와 데이터셋 ${DATASET_KEY} 의 이용 신청(승인) 상태를 확인하세요."
            exit 1
        fi

        if [[ $attempt -lt $RETRIES ]]; then
            log "  ${RETRY_WAIT}초 후 다시 시도합니다."
            sleep "$RETRY_WAIT"
        fi
    done

    if [[ $ok -eq 1 ]]; then
        n_ok=$((n_ok + 1))
    else
        failed+=("$key $name ($size)")
    fi
done

log "결과: 새로 받음 ${n_ok}개, 이미 완료 ${n_skip}개, 실패 ${#failed[@]}개 / 대상 ${total}개"
if [[ ${#failed[@]} -gt 0 ]]; then
    log "실패한 파일 (다시 실행하면 이 파일들만 받습니다):"
    printf '  %s\n' "${failed[@]}"
    exit 1
fi

log "모든 파일 다운로드 완료: $OUT_DIR"
