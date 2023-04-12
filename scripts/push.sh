#!/bin/bash
set -e -x

echo "IMAGE: ${IMAGE}"

if [ "x${IMAGE}" == "x" ]; then
  echo Environment variable IMAGE is required.
  exit 1
fi

docker push "${IMAGE}"

docker image rm "${IMAGE}"
