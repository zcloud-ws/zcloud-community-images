ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG USER=zcloud

RUN apk add --no-cache bash curl zip

# Create user and group with UID and GID 65123
RUN adduser -s /bin/bash -D -u 65123 $USER

SHELL ["bash", "-l", "-c"]

USER $USER

WORKDIR /home/$USER

ENTRYPOINT ["bash", "-l"]

