# Broadcast private wrapper template

This directory contains a **customer-owned private wrapper template** for running
licensed Broadcast installations with Quave ONE.

It is not a public Broadcast image. It does not contain Broadcast source code,
binaries, license keys, registry credentials, or any other Broadcast software
artifact.

## Relationship with Broadcast

Quave is not affiliated with, endorsed by, sponsored by, or partnered with
Broadcast or Furvur Inc.

Broadcast is proprietary self-hosted software. Before using this template, the
customer must have a valid Broadcast license and must follow Broadcast's terms,
including the allowed number of servers and allowed hosting locations.

Relevant Broadcast links:

- Installation guide: <https://sendbroadcast.net/installation>
- Terms: <https://sendbroadcast.net/terms>

## What this template does

The `Dockerfile` is intentionally small:

```dockerfile
ARG BROADCAST_IMAGE=gitea.hostedapp.org/broadcast/broadcast:latest
FROM ${BROADCAST_IMAGE}
```

It lets a licensed customer build a private image from the official Broadcast
image that their license allows them to pull. The resulting image should stay in
the customer's private registry unless Broadcast/Furvur explicitly authorizes
redistribution.

## What this template does not do

This template does not:

- publish a Quave-provided Broadcast image;
- redistribute Broadcast software;
- include a Broadcast license key;
- include Broadcast registry credentials;
- bypass Broadcast license checks;
- modify Broadcast application code;
- replace Broadcast support or documentation.

## Customer prerequisites

The customer needs:

1. A valid Broadcast license.
2. The installation domain, for example `broadcast.example.com`.
3. Access to the official Broadcast image or registry credentials provided by
   Broadcast's license flow.
4. A private registry where the customer can store the wrapper image, for example
   private GHCR, private Docker Hub, ECR, GCR, or another private registry.
5. A Quave ONE account and MCP key with scopes to create apps, environments,
   credentials, hosts, and deployments.

Broadcast's public installer validates the license and receives registry details
from Broadcast. Keep those values secret. Do not commit them to this repository,
Dockerfiles, CI logs, or public issue comments.

## Build locally

Run these commands in your private fork or private copy after setting the values
provided by your Broadcast license flow:

```bash
export BROADCAST_REGISTRY_URL="gitea.hostedapp.org"
export BROADCAST_REGISTRY_USERNAME="..."
export BROADCAST_REGISTRY_PASSWORD="..."
export BROADCAST_IMAGE="gitea.hostedapp.org/broadcast/broadcast:latest"
export PRIVATE_IMAGE="ghcr.io/YOUR_ORG/broadcast:latest"

echo "$BROADCAST_REGISTRY_PASSWORD" | docker login "$BROADCAST_REGISTRY_URL" \
  --username "$BROADCAST_REGISTRY_USERNAME" \
  --password-stdin

docker build \
  --build-arg BROADCAST_IMAGE="$BROADCAST_IMAGE" \
  -t "$PRIVATE_IMAGE" \
  broadcast

docker push "$PRIVATE_IMAGE"
```

Keep `$PRIVATE_IMAGE` private unless Broadcast/Furvur explicitly allows you to
redistribute it.

## Build with GitHub Actions

Copy `examples/build-private-wrapper.github-actions.yml` into your private
repository as `.github/workflows/build-broadcast.yml`.

Add these GitHub Secrets in the private repository:

| Secret | Description |
| --- | --- |
| `BROADCAST_REGISTRY_URL` | Registry host returned by Broadcast's license flow. |
| `BROADCAST_REGISTRY_USERNAME` | Registry username returned by Broadcast's license flow. |
| `BROADCAST_REGISTRY_PASSWORD` | Registry password returned by Broadcast's license flow. |
| `BROADCAST_IMAGE` | Official Broadcast image reference, including tag. |

The example workflow pushes to that repository's GHCR namespace. Keep the package
private.

## Deploy to Quave ONE with MCP

After the private image exists, paste this into your MCP-enabled agent and replace
the uppercase placeholders:

```text
Use Quave ONE MCP to deploy this licensed Broadcast installation.

Important constraints:
- Quave is not affiliated with Broadcast or Furvur Inc.
- The customer has a valid Broadcast license.
- Do not publish or redistribute the Broadcast image publicly.
- Use the customer's private image and private registry credential only.
- Confirm the selected Quave ONE region is allowed by the customer's Broadcast license.

Deployment details:
- Customer/account: CUSTOMER_ACCOUNT_NAME_OR_ID
- App name: broadcast
- Environment: production
- Region: QUAVE_ONE_REGION
- Public host: broadcast.example.com
- App port: 3000, unless the customer's Broadcast image documentation says otherwise
- Private image: PRIVATE_IMAGE_WITH_TAG
- Registry credential: PRIVATE_REGISTRY_CREDENTIAL_NAME_OR_ID

Please do the whole deployment:
1. Find the Quave ONE account, or ask me only if it is ambiguous.
2. Create or reuse a Container Registry credential for the private registry.
3. Create the app as an image-based app with useImage=true, the private image, and the app port above.
4. Create or select the production environment in the requested region.
5. Configure required environment variables and secrets from the customer's Broadcast documentation. Do not invent secrets and do not bake them into the image.
6. Attach the public host broadcast.example.com.
7. Deploy the image.
8. Monitor status, containers, logs, and health checks until it is running or until you find a concrete blocker.
9. Report the DNS record that the customer needs to create.
10. Finish with the app URL, deployment status, and remaining Broadcast setup steps.
```

## Operational notes

Broadcast's public installation guide targets a fresh Ubuntu server and uses its
own Docker Compose based installation. A Quave ONE deployment should use the
container image and runtime configuration directly instead of running the VPS
installer inside an application container.

If your Broadcast deployment needs a separate Postgres database, background job
process, persistent storage, or additional runtime commands, model those as
separate Quave ONE resources or jobs according to the customer's Broadcast
license and documentation.
