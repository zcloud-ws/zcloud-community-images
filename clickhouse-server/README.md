# ClickHouse Server with Custom Configuration

This Docker image extends the official ClickHouse server with additional configuration capabilities through environment variables.

## Features

- Based on the official ClickHouse server image
- Support for custom XML configuration via environment variable
- Automatic XML validation before server startup
- All standard ClickHouse environment variables supported

## Environment Variables

### Custom Variables

- **`CUSTOM_CONFIG`**: Additional XML server configuration that will be saved to `/etc/clickhouse-server/config.d/custom.xml`. The XML content will be validated before the server starts. If validation fails, the container will exit with an error.

### Standard ClickHouse Environment Variables

The following environment variables are inherited from the official ClickHouse Docker image:

- **`CLICKHOUSE_DB`**: Database name to create on first startup (default: none)
- **`CLICKHOUSE_USER`**: Username to create on first startup (default: `default`)
- **`CLICKHOUSE_PASSWORD`**: Password for the user (default: empty)
- **`CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT`**: Enable SQL-driven access control and account management (default: `0`)
- **`CLICKHOUSE_CONFIG`**: Path to the main configuration file (default: `/etc/clickhouse-server/config.xml`)

## Usage Example

```bash
docker run -d \
  -e CLICKHOUSE_USER=admin \
  -e CLICKHOUSE_PASSWORD=secret \
  -e CUSTOM_CONFIG='<clickhouse><max_connections>1000</max_connections></clickhouse>' \
  -p 8123:8123 \
  -p 9000:9000 \
  your-image-name
```

## Custom Configuration

The `CUSTOM_CONFIG` variable allows you to inject additional XML configuration without building a custom image. The configuration is validated using `xmllint` if available.

Example custom configuration:
```xml
<clickhouse>
    <max_connections>1000</max_connections>
    <max_concurrent_queries>100</max_concurrent_queries>
    <listen_host>::</listen_host>
</clickhouse>
```

## Notes

- XML validation requires `xmllint` to be available in the container
- Invalid XML in `CUSTOM_CONFIG` will prevent the container from starting
- Custom configuration is merged with the default ClickHouse configuration

_by [Quave](https://www.quave.cloud)_
