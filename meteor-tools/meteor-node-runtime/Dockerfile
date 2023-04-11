ARG BASE_IMAGE

FROM $BASE_IMAGE as builder

MAINTAINER zcloud.ws

USER root

RUN mkdir -p /tmp/tools/.node && chown zcloud:zcloud -R /tmp/tools

USER zcloud

RUN export DEV_BUNDLE_DIR="$(meteor node -e 'console.log(process.env.NPM_CONFIG_PREFIX)')" && \
    cp -r $DEV_BUNDLE_DIR/{bin,lib} /tmp/tools/.node/

FROM docker.io/zcloudws/ubuntu-base:22.04

COPY --from=builder /tmp/tools/.node /home/zcloud/.node

RUN mkdir $HOME/bin && \
    ln -s $HOME/.node/bin/{node,npm,npx} $HOME/bin/


