#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

USAGE="
Usage: ${BASH_SOURCE[0]} [options] command

Available command are:
  create-cache
  extract-cache
  install-packages
  test
  build
  deploy

Available options are:
  -h, --help       Print this message.
  --               Stop handling options.
"

cd "$ROOT_DIR" || exit 1

CI_PYPI_REPOSITORY_URL="${CI_SERVER_URL}/api/v4/projects/${CI_PROJECT_ID}/packages/pypi"
CACHE_ARCHIVE=$ROOT_DIR/cache.tar.gz
CACHES=(
    "$ROOT_DIR/.venv/"
    "$ROOT_DIR/.mypy_cache/"
    "$ROOT_DIR/.pytest_cache/"
)

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

trap 'cancel_black' INT

function cancel_black
{
    print_error "An interrupt signal was detected."
    exit 1
}

function print_usage
{
    echo "$USAGE"
}

function exit_on_error
{
    local code=$?
    if [[ $code -ne 0 ]]; then
        exit $code
    fi
}

function exit_on_result_error
{
    for i in "$@"; do
        if [[ $i -ne 0 ]]; then
            exit 1
        fi
    done
}

function run_create_cache
{
    if [[ -f "$CACHE_ARCHIVE" ]]; then
        rm -v "$CACHE_ARCHIVE"
    fi

    local files
    for f in "${CACHES[@]}"; do
        if [[ -e "$f" ]]; then
            files+=("$f")
        fi
    done

    print_message "Creating cache ..."
    for f in "${files[@]}"; do
        print_message " - Cache '$f'"
    done

    tar -czf "$CACHE_ARCHIVE" "${files[@]}"
    print_message "Cache creation complete!"
}

function run_extract_cache
{
    if [[ ! -f "$CACHE_ARCHIVE" ]]; then
        return
    fi

    print_message "Extracting cache ..."
    tar -xzf "$CACHE_ARCHIVE"
    print_message "Cache extraction complete!"
}

function run_install_packages
{
    print_message "Install python packages"

    bash "$ROOT_DIR/python" -m pip install -U pip
    exit_on_error

    bash "$ROOT_DIR/python" -m pip install -r "$ROOT_DIR/requirements.txt"
    exit_on_error
}

function run_test
{
    print_message "Run python tests"
    bash "$ROOT_DIR/black.sh"  ; BLACK_RESULT=$?
    bash "$ROOT_DIR/flake8.sh" ; FLAKE8_RESULT=$?
    bash "$ROOT_DIR/isort.sh"  ; ISORT_RESULT=$?
    bash "$ROOT_DIR/mypy.sh"   ; MYPY_RESULT=$?
    bash "$ROOT_DIR/pytest.sh" ; PYTEST_RESULT=$?

    exit_on_result_error \
        $BLACK_RESULT \
        $FLAKE8_RESULT \
        $ISORT_RESULT \
        $MYPY_RESULT \
        $PYTEST_RESULT
}

function run_build
{
    print_message "Build the backend"
    bash "$ROOT_DIR/build.sh"
    exit_on_error
}

function run_deploy
{
    local repository_url
    local username
    local password

    repository_url="${PYPI_REPOSITORY_URL:-$CI_PYPI_REPOSITORY_URL}"

    # GitLab > User Settings > Personal Access Tokens
    # Name is {PYPI_USERNAME}
    # Token is {PYPI_PASSWORD}
    # Scopes is api
    username="${PYPI_USERNAME}"
    password="${PYPI_PASSWORD}"

    if [[ -z $username ]]; then
        print_error "Undefined repository username"
        exit 1
    fi
    if [[ -z $password ]]; then
        print_error "Undefined repository password"
        exit 1
    fi

    print_message "Deploy to '${repository_url}'"
    bash "$ROOT_DIR/python" -m twine upload \
        --repository-url "${repository_url}" \
        --username "${username}" \
        --password "${password}" \
        "$ROOT_DIR/dist/*"
    exit_on_error
}

while [[ -n $1 ]]; do
    case $1 in
    -h|--help)
        print_usage
        exit 0
        ;;
    --)
        shift
        break
        ;;
    *)
        break
        ;;
    esac
done

if [[ -z $1 ]]; then
    print_error "Empty 'command' argument"
    exit 1
fi

COMMAND=$1
shift

case "$COMMAND" in
    create-cache|create_cache)
        run_create_cache
        ;;
    extract-cache|extract_cache)
        run_extract_cache
        ;;
    install-packages|install_packages)
        run_install_packages
        ;;
    test)
        run_test
        ;;
    build)
        run_build
        ;;
    deploy)
        run_deploy
        ;;
    *)
        print_error "Unknown command '$COMMAND'"
        exit 1
        ;;
esac

