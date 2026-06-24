#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"
env_file="${script_dir}/.env"

if [ -f "${env_file}" ]; then
    set -a
    # shellcheck disable=SC1090
    source "${env_file}"
    set +a
fi

ROS1_WS="${ROS1_WS:-${repo_root}}"
ROS_IMAGE="${ROS_IMAGE:-local/kinesis-rb-car-noetic:desktop}"
CONTAINER_NAME="${CONTAINER_NAME:-kinesis_rb_car_noetic}"
CONTAINER_WORKSPACE="${CONTAINER_WORKSPACE:-/home/ros/rb-car_ws}"

if ! docker info >/dev/null 2>&1; then
    echo "Docker is not reachable from this shell." >&2
    echo "If you recently joined the docker group, run: newgrp docker" >&2
    echo "Otherwise check that Docker is installed and the daemon is running." >&2
    exit 1
fi

if ! docker image inspect "${ROS_IMAGE}" >/dev/null 2>&1; then
    "${script_dir}/build.sh"
fi

mkdir -p "${ROS1_WS}/src"
xhost +local:docker >/dev/null 2>&1 || true

docker_args=(
    -it --rm
    --name "${CONTAINER_NAME}"
    --net=host
    --ipc=host
    -e DISPLAY="${DISPLAY:-}"
    -e XDG_RUNTIME_DIR=/tmp/runtime-ros
    -e QT_X11_NO_MITSHM=1
    -e LIBGL_ALWAYS_INDIRECT="${LIBGL_ALWAYS_INDIRECT:-0}"
    -e ROS_MASTER_URI="${ROS_MASTER_URI:-http://localhost:11311}"
    -e ROS_IP="${ROS_IP:-127.0.0.1}"
    -e ROS_WORKSPACE="${CONTAINER_WORKSPACE}"
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw
    -v "${ROS1_WS}:${CONTAINER_WORKSPACE}:rw"
    -w "${CONTAINER_WORKSPACE}"
)

if [ -n "${XAUTHORITY:-}" ] && [ -f "${XAUTHORITY}" ]; then
    docker_args+=(
        -e XAUTHORITY=/tmp/.docker.xauth
        -v "${XAUTHORITY}:/tmp/.docker.xauth:ro"
    )
fi

if [ -d /dev/dri ]; then
    docker_args+=(--device /dev/dri)

    video_gid="$(getent group video | cut -d: -f3 || true)"
    render_gid="$(getent group render | cut -d: -f3 || true)"

    if [ -n "${video_gid}" ]; then
        docker_args+=(--group-add "${video_gid}")
    fi

    if [ -n "${render_gid}" ]; then
        docker_args+=(--group-add "${render_gid}")
    fi
fi

if [ -d "${HOME}/.ssh" ]; then
    docker_args+=(-v "${HOME}/.ssh:/home/ros/.ssh:ro")
fi

if [ -f "${HOME}/.gitconfig" ]; then
    docker_args+=(-v "${HOME}/.gitconfig:/home/ros/.gitconfig:ro")
fi

docker run "${docker_args[@]}" \
    "${ROS_IMAGE}" \
    bash -lc 'mkdir -p "${XDG_RUNTIME_DIR}" && chmod 700 "${XDG_RUNTIME_DIR}" && exec bash'
