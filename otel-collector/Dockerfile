FROM alpine:3.23.2

ARG OTEL_VERSION=0.143.0

RUN apk add --no-cache \
    ca-certificates \
    curl \
    libc6-compat \
    tar

RUN curl -L -f "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTEL_VERSION}/otelcol_${OTEL_VERSION}_linux_amd64.tar.gz" -o otelcol.tar.gz && \
    tar -xzf otelcol.tar.gz && \
    mv otelcol /usr/bin/otelcol && \
    rm otelcol.tar.gz && \
    chmod +x /usr/bin/otelcol

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && \
    chmod +x /entrypoint.sh

RUN mkdir -p /etc/otelcol

ENTRYPOINT ["/entrypoint.sh"]