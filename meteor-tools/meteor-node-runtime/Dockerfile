ARG BASE_IMAGE
ARG RUNTIME_BASE_IMAGE=docker.io/zcloudws/ubuntu-base:22.04

FROM $BASE_IMAGE as builder

ARG METEOR_TOOL_VERSION="*.*.*"

LABEL maintainer="zcloud.ws"

USER root

RUN mkdir -p /tmp/tools/.node && chown zcloud:zcloud -R /tmp/tools

USER zcloud

RUN export DEV_BUNDLE_DIR=.meteor/packages/meteor-tool/${METEOR_TOOL_VERSION}/mt-os.linux.x86_64/dev_bundle && \
    cp -r $DEV_BUNDLE_DIR/{bin,lib} /tmp/tools/.node/

FROM $RUNTIME_BASE_IMAGE

USER root

# Node 26+ (Meteor 3.6+) links libatomic.so.1, which ubuntu-base lacks.
RUN apt-get update && apt-get install -y --no-install-recommends libatomic1 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/tools/.node /opt/zcloud/nodejs/

RUN mkdir /built_app && chown zcloud:zcloud -R /built_app

RUN ln -s /opt/zcloud/nodejs/bin/{node,npm,npx} /usr/local/bin/

# Trust the Quave One root CA that the platform mounts in every container, so
# Node.js reaches platform services with internal certificates (e.g. managed
# MongoDB). Additive to Node's bundled roots; Node only warns when the file is
# missing (outside Quave One).
ENV NODE_EXTRA_CA_CERTS=/quave-one-tls/ca.crt

COPY scripts /scripts

USER zcloud

ENTRYPOINT ["/scripts/startup.sh"]
