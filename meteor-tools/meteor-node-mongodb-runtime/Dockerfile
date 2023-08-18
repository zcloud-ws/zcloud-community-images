ARG BASE_IMAGE

FROM $BASE_IMAGE as builder

MAINTAINER zcloud.ws

USER root

RUN mkdir -p /tmp/tools/{.node,.mongodb} && chown zcloud:zcloud -R /tmp/tools

USER zcloud

RUN export DEV_BUNDLE_DIR=.meteor/packages/meteor-tool/*.*.*/mt-os.linux.x86_64/dev_bundle && \
    cp -r $DEV_BUNDLE_DIR/{bin,lib} /tmp/tools/.node && \
    cp -r $DEV_BUNDLE_DIR/mongodb/bin /tmp/tools/.mongodb/

FROM docker.io/zcloudws/ubuntu-base:22.04

USER root

COPY --from=builder /tmp/tools/.node /opt/zcloud/nodejs/
COPY --from=builder /tmp/tools/.mongodb /opt/zcloud/mongodb/

RUN mkdir /{built_app,mongodb-data} && chown zcloud:zcloud -R /{built_app,mongodb-data}

RUN ln -s /opt/zcloud/nodejs/bin/{node,npm,npx} /usr/local/bin/ && \
    ln -s /opt/zcloud/mongodb/bin/mongod /usr/local/bin/

COPY scripts /scripts

USER zcloud

ENTRYPOINT ["/scripts/startup.sh"]
