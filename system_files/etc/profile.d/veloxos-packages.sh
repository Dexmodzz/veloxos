#!/usr/bin/env bash
# VeloxOS package root environment integration.

VELOXOS_ROOT="/var/lib/veloxos/packages"

if [[ -d "$VELOXOS_ROOT/usr" ]]; then
    export PATH="$VELOXOS_ROOT/usr/bin:$VELOXOS_ROOT/usr/sbin:$PATH"
    export XDG_DATA_DIRS="$VELOXOS_ROOT/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    export MANPATH="$VELOXOS_ROOT/usr/share/man${MANPATH:+:$MANPATH}"
    export GI_TYPELIB_PATH="$VELOXOS_ROOT/usr/lib64/girepository-1.0:$VELOXOS_ROOT/usr/lib/girepository-1.0${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
fi
