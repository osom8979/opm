#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
# shellcheck source=common.sh
source "$ROOT_DIR/common.sh"

# Images are rebuilt under the same tag, so compare IDs to find stale containers
function show_service
{
    local service=$1 image image_id created container_id state
    image=$(service_image "$service")
    image_id=$(docker image inspect -f '{{.Id}}' "$image" 2> /dev/null)
    created=$(docker image inspect -f '{{.Created}}' "$image" 2> /dev/null)
    container_id=$(compose ps -q "$service")

    if [[ -z $container_id ]]; then
        state="not running"
    elif [[ -z $image_id ]]; then
        state="running, but '$image' is not pulled"
    elif [[ $(docker inspect -f '{{.Image}}' "$container_id") == "$image_id" ]]; then
        state="running"
    else
        state="running an older image (run 'docker compose up -d $service')"
    fi

    print_message "[$service]"
    echo "  image     : $image"
    echo "  built     : ${created:-not pulled}"
    echo "  container : $state"
}

show_service traefik
show_service mariadb
show_service mediawiki

# shellcheck disable=SC2016
VERSIONS_COMMAND='echo "$MEDIAWIKI_VERSION" "$(php -r "echo PHP_VERSION;")"'
if is_running mediawiki; then
    read -r MW_VERSION PHP_VERSION < <(compose exec -T mediawiki sh -c "$VERSIONS_COMMAND")
else
    MEDIAWIKI_IMAGE=$(service_image mediawiki)
    read -r MW_VERSION PHP_VERSION < <(docker run --rm --entrypoint sh "$MEDIAWIKI_IMAGE" -c "$VERSIONS_COMMAND" 2> /dev/null)
fi
echo "  MediaWiki : ${MW_VERSION:-unknown}"
echo "  PHP       : ${PHP_VERSION:-unknown}"

SMJ_VERSION=$(sed -n 's/^[[:space:]]*"version": "\(.*\)",$/\1/p' "$ROOT_DIR/SimpleMathJax/extension.json" 2> /dev/null)
print_message "[SimpleMathJax]"
echo "  version   : ${SMJ_VERSION:-not initialized (run ./update-submodule.sh)}"
