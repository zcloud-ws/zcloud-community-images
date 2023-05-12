#!/usr/bin/env sh

export NEXT_VERSION
CURRENT_VERSION="$(cat "${1}" 2>/dev/null || echo -n 0)"

NEXT_VERSION=$((1 + CURRENT_VERSION))
echo $NEXT_VERSION
