# Jaeger All-in-One with Nginx Auth

Jaeger All-in-One distribution with a pre-configured Nginx reverse proxy for Basic Authentication and OTLP support.

### Usage example

```bash
docker run --rm --name jaeger \
  -e JAEGER_USER=admin \
  -e JAEGER_PASSWORD=yourpassword \
  -p 16686:16686 -p 16687:16687 -p 4318:4318 \
  -it zcloudws/jaeger:1.65.0
```

_by [Quave](https://www.quave.dev)_
