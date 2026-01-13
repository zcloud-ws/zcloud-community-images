# OpenTelemetry Collector (Alpine)

A lightweight OpenTelemetry Collector image based on Alpine Linux, designed for high-performance telemetry processing.

### Usage example

```bash
docker run --rm --name otel-collector \
  -e OTEL_CONFIG_CONTENT="<your-yaml-config-here>" \
  -p 4318:4318 \
  -it zcloudws/otel-collector:0.117.0
```