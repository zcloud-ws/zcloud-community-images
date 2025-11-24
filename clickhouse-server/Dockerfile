ARG BASE_IMAGE

FROM $BASE_IMAGE

# Install xmllint for XML validation
RUN apk add --no-cache libxml2-utils

COPY custom-entrypoint.sh /custom-entrypoint.sh

RUN chmod +x /custom-entrypoint.sh

CMD ["/custom-entrypoint.sh"]
