# HTTP Redirect Server

A lightweight HTTP redirect server built with Bun that handles 301, 302, and 307 redirects based on JSON configuration.

## Configuration

The server reads redirect rules from the `REDIRECT_CONFIG` environment variable. The configuration should be a JSON array of redirect objects with the following structure:

```json
[
  {
    "hostFrom": "old-domain.com",
    "hostTo": "new-domain.com",
    "httpCode": 301,
    "scheme": "https:"
  },
  {
    "hostFrom": "temp-domain.com",
    "hostTo": "example.com",
    "httpCode": 302
  },
  {
    "hostFrom": "old-domain.com",
    "hostTo": "new-domain.com",
    "pathPrefixTo": "/blog",
    "httpCode": 301,
    "scheme": "https:"
  },
]
```

Each redirect object requires:
- `hostFrom`: The source hostname to match
- `hostTo`: The destination hostname
- `httpCode`: HTTP status code (301 for permanent redirect, 302 or 307 for temporary redirects)
  - 301: Permanent Redirect
  - 302: Found (Temporary Redirect)
  - 307: Temporary Redirect (preserves the request method)

Optional fields:
- `scheme`: The protocol to use in the redirect URL ("http:" or "https:")
  - If not specified, the original request's protocol will be preserved
- `pathPrefixTo`: Path to use as prefix path

## Using with Quave Cloud

To use this redirect service with Quave Cloud:

1. Point a CNAME record from your domain to `auto-redirect.quave.cloud`
2. Configure your redirect rules using the `REDIRECT_CONFIG` environment variable in your Quave Cloud deployment settings

Example CNAME configuration:
```dns
old-domain.com.    CNAME    auto-redirect.quave.cloud.
```

The redirect service will automatically handle requests to your domain based on the configured redirect rules.

## Usage

1. Install dependencies:

```bash
bun install
```

2. Set the redirect configuration:

```bash
export REDIRECT_CONFIG='[{"hostFrom":"old-domain.com","hostTo":"new-domain.com","httpCode":301}]'
```

3. Start the server:

```bash
bun start
```

The server will listen on port 3000 by default. You can override this by setting the `PORT` environment variable.

## Error Handling

The server will exit with an error if:
- The `REDIRECT_CONFIG` environment variable is not set
- The JSON configuration is invalid
- The redirect rules don't follow the required format
