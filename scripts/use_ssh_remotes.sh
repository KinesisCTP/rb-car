#!/usr/bin/env bash
set -euo pipefail

workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set_origin() {
    local path="$1"
    local repo="$2"

    if [ ! -d "${workspace_root}/src/${path}/.git" ]; then
        echo "Skipping ${path}: not cloned"
        return
    fi

    git -C "${workspace_root}/src/${path}" remote set-url origin "git@github.com:KinesisCTP/${repo}.git"
    echo "Updated ${path} origin -> KinesisCTP/${repo}"
}

set_origin rbcar_common rbcar_common
set_origin rbcar_sim rbcar_sim
set_origin robotnik_msgs robotnik_msgs
set_origin robotnik_sensors robotnik_sensors
