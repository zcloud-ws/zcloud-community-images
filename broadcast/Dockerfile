# syntax=docker/dockerfile:1
#
# Public Broadcast installer/launcher image for licensed customers.
#
# This image does NOT contain Broadcast application code or binaries. It contains
# Quave's Docker-based launcher that validates the customer's Broadcast license,
# logs in to Broadcast's registry using credentials returned by Broadcast, and
# starts the official Broadcast containers on the customer's Docker host.

FROM docker:27-cli

ARG IMAGE_VERSION=dev

LABEL org.opencontainers.image.title="Broadcast Docker launcher for licensed customers"
LABEL org.opencontainers.image.description="Public Quave launcher image. It does not include Broadcast software; customers must provide their own Broadcast license at runtime."
LABEL org.opencontainers.image.vendor="Quave"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL com.quave-one.template="broadcast-docker-launcher"
LABEL com.quave-one.broadcast.affiliation="Quave is not affiliated with Broadcast or Furvur Inc."

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    docker-cli-compose \
    jq \
    openssl

WORKDIR /launcher

COPY entrypoint.sh /usr/local/bin/broadcast-launcher

RUN chmod +x /usr/local/bin/broadcast-launcher

ENTRYPOINT ["broadcast-launcher"]
CMD ["install"]
