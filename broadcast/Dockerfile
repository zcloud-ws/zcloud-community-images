# syntax=docker/dockerfile:1
#
# Customer-built Broadcast wrapper image.
#
# This Dockerfile intentionally does not download, vendor, or redistribute
# Broadcast. It only lets a licensed Broadcast customer build a private wrapper
# image from the official Broadcast image that their license allows them to pull.
#
# Usage:
#   docker login "$BROADCAST_REGISTRY_URL" \
#     --username "$BROADCAST_REGISTRY_USERNAME" \
#     --password-stdin
#   docker build \
#     --build-arg BROADCAST_IMAGE="$BROADCAST_IMAGE" \
#     -t ghcr.io/YOUR_ORG/broadcast:YOUR_TAG \
#     broadcast
#
# Keep the resulting image private unless Broadcast/Furvur explicitly authorizes
# redistribution.

ARG BROADCAST_IMAGE=gitea.hostedapp.org/broadcast/broadcast:latest
FROM ${BROADCAST_IMAGE}

LABEL org.opencontainers.image.title="Broadcast private customer wrapper"
LABEL org.opencontainers.image.description="Private wrapper for licensed Broadcast customers. Does not contain Quave-owned Broadcast code and is not published by Quave."
LABEL org.opencontainers.image.vendor="Customer-built; not affiliated with Broadcast or Furvur Inc."
LABEL com.quave-one.template="broadcast-private-wrapper"
