#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)"

if ! command -v opm-home &> /dev/null; then
PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../bin" || exit; pwd):$PATH"
fi

if ! command -v opm-home &> /dev/null; then
    echo "Not found opm-home command" 1>&2
    exit 1
fi


USAGE="
Usage: ${BASH_SOURCE[0]} [options]

Run HashiCorp Vault container.

Available options are:
  -r, --runtime {docker|podman}  Specify container runtime.
  -h, --help                     Print this message.

If no runtime is specified, auto-selects: docker -> podman.
"

function detect_runtime
{
    if command -v docker &> /dev/null; then
        echo "docker"
    elif command -v podman &> /dev/null; then
        echo "podman"
    else
        return 1
    fi
}

function resolve_image
{
    local runtime=$1
    if [[ "$runtime" == "podman" ]]; then
        echo "docker.io/hashicorp/vault:latest"
    else
        echo "hashicorp/vault:latest"
    fi
}

function print_error
{
    # shellcheck disable=SC2145
    echo -e "\033[31m$@\033[0m" 1>&2
}

function print_message
{
    # shellcheck disable=SC2145
    echo -e "\033[32m$@\033[0m"
}

function on_interrupt_trap
{
    print_error "An interrupt signal was detected."
    exit 1
}

function print_usage
{
    echo "$USAGE"
}

trap on_interrupt_trap INT

function run_vault_server_main
{
    local runtime=""

    while [[ $# -gt 0 ]]; do
        case $1 in
        -h|--help)
            print_usage
            return 0
            ;;
        -r|--runtime)
            runtime="${2:-}"
            if [[ -z "$runtime" ]]; then
                print_error "Missing value for $1"
                return 1
            fi
            shift 2
            ;;
        --)
            shift
            break
            ;;
        -*)
            print_error "Unknown option: $1"
            return 1
            ;;
        *)
            print_error "Unknown argument: $1"
            return 1
            ;;
        esac
    done

    if [[ -z "$runtime" ]]; then
        runtime=$(detect_runtime) || {
            print_error "Neither docker nor podman found."
            return 1
        }
        print_message "Auto-selected runtime: $runtime"
    fi

    if ! command -v "$runtime" &> /dev/null; then
        print_error "Not found $runtime command."
        return 1
    fi

    local image
    image=$(resolve_image "$runtime")

    "$runtime" run -d \
        --name vault-server \
        --restart unless-stopped \
        --cap-add IPC_LOCK \
        -p 8200:8200 \
        -e VAULT_ADDR="http://0.0.0.0:8200" \
        -e VAULT_API_ADDR="http://0.0.0.0:8200" \
        -v "$SCRIPT_DIR/config:/vault/config:ro" \
        -v "$(opm-home)/var/vault/data:/vault/data" \
        -v "$(opm-home)/var/vault/logs:/vault/logs" \
        "$image" server
}

run_vault_server_main "$@"
