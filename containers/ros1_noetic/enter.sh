#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="${script_dir}/.env"

if [ -f "${env_file}" ]; then
    set -a
    # shellcheck disable=SC1090
    source "${env_file}"
    set +a
fi

CONTAINER_NAME="${CONTAINER_NAME:-kinesis_rb_car_noetic}"
CONTAINER_WORKSPACE="${CONTAINER_WORKSPACE:-/home/ros/rb-car_ws}"

if ! docker info >/dev/null 2>&1; then
    echo "Docker is not reachable from this shell." >&2
    echo "If you recently joined the docker group, run: newgrp docker" >&2
    exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -Fxq "${CONTAINER_NAME}"; then
    echo "Container ${CONTAINER_NAME} is not running." >&2
    echo "Start it with: ${script_dir}/run.sh" >&2
    exit 1
fi

docker exec -it "${CONTAINER_NAME}" bash -lc "cd '${CONTAINER_WORKSPACE}' && exec bash"
