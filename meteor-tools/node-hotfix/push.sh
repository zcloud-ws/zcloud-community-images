#!/usr/bin/env bash
# Pushes the images listed by build.sh.
# Usage: ./push.sh
set -euo pipefail

cd "$(dirname "$0")"
TAGS_FILE="${TAGS_FILE:-.hotfix-tags}"
test -s "${TAGS_FILE}"

while read -r IMAGE; do
  IMAGE="${IMAGE}" ../../scripts/push.sh
done < "${TAGS_FILE}"
