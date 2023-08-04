ARG BASE_IMAGE

FROM $BASE_IMAGE as builder

MAINTAINER zcloud.ws

USER root

RUN mkdir -p /tmp/tools/.node && chown zcloud:zcloud -R /tmp/tools

USER zcloud

RUN export DEV_BUNDLE_DIR=.meteor/packages/meteor-tool/*.*.*/mt-os.linux.x86_64/dev_bundle && \
    cp -r $DEV_BUNDLE_DIR/{bin,lib} /tmp/tools/.node/

FROM docker.io/zcloudws/ubuntu-base:22.04

USER root

COPY --from=builder /tmp/tools/.node /opt/zcloud/nodejs/

RUN mkdir /built_app && chown zcloud:zcloud -R /built_app

RUN ln -s /opt/zcloud/nodejs/bin/{node,npm,npx} /usr/local/bin/

COPY scripts /scripts

USER zcloud

ENTRYPOINT ["/scripts/startup.sh"]

