#!/bin/bash
set -e

TOKEN="$(curl -s -X POST https://hub.docker.com/v2/users/login \
     -H 'Content-Type: application/json' \
     -d  "{\"username\":\"${ZC_USERNAME}\",\"password\":\"${ZC_TOKEN}\"}" | grep -Po 'ey.*[^"}]')"
#| grep -Po '"token":.*?[^\\]",' || echo ''
if [ "x${TOKEN}" != "x" ]; then
  curl -X PATCH https://hub.docker.com/v2/repositories/${IMAGE_REPO}/${IMAGE_NAME} \
       -H 'Content-Type: application/json' \
       -H "Authorization: JWT ${TOKEN}"  \
       -d  "${README_BODY}" || true
fi
