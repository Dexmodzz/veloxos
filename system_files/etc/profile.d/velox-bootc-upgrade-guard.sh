#!/usr/bin/env bash
# VeloxOS: guard against bare `bootc upgrade`. Each build now ships under
# its own unique image tag, so `bootc upgrade` alone only re-checks the
# exact tag currently deployed and can never advance to a newer build on
# its own — use `velox upgrade` instead, which resolves the latest build
# and switches to it.
#
# Wraps both `bootc` (root shells) and `sudo` (the common
# `sudo bootc upgrade` invocation), since sudo execs its target directly
# and never consults the calling shell's functions.

_velox_bootc_upgrade_blocked() {
    [[ "${1:-}" == "upgrade" ]] || return 1
    local arg
    for arg in "$@"; do
        [[ "$arg" == "--check" ]] && return 1
    done
    echo "VeloxOS: 'bootc upgrade' won't find newer builds — each build ships under its own image tag." >&2
    echo "Use 'sudo velox upgrade' to check for and apply the latest VeloxOS build." >&2
    echo "(Run 'command sudo bootc upgrade' to bypass this.)" >&2
    return 0
}

bootc() {
    _velox_bootc_upgrade_blocked "$@" && return 1
    command bootc "$@"
}

sudo() {
    if [[ "${1:-}" == "bootc" ]]; then
        shift
        _velox_bootc_upgrade_blocked "$@" && return 1
        command sudo bootc "$@"
        return
    fi
    command sudo "$@"
}
