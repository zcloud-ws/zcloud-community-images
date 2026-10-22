# Hotfix layer: replaces only the Node.js binary of a published Meteor runtime
# image with an official, verified build (see verify-node-release.sh). npm,
# MongoDB, the startup scripts and everything else stay as in BASE_IMAGE.
ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG BASE_IMAGE
ARG NODE_VERSION

LABEL maintainer="zcloud.ws" \
      ws.zcloud.meteor.node-hotfix="${NODE_VERSION}" \
      ws.zcloud.meteor.base-image="${BASE_IMAGE}"

COPY --chown=zcloud:zcloud --chmod=0755 node /opt/zcloud/nodejs/bin/node

RUN test "$(node -v)" = "v${NODE_VERSION}"
