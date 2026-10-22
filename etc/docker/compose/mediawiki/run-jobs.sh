#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

# Run as www-data, or files created in images/ become unwritable for the wiki.
# maintenance/run.php exists since MediaWiki 1.40
# shellcheck disable=SC2016
docker compose -f "$ROOT_DIR/docker-compose.yml" run --rm --no-deps --user www-data mediawiki sh -c '
    if [ -f maintenance/run.php ]; then
        exec php maintenance/run.php runJobs "$@"
    fi
    exec php maintenance/runJobs.php "$@"
' run-jobs "$@"
