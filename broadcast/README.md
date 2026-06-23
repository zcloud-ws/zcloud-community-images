# Broadcast Docker launcher

`zcloudws/broadcast` is a public Docker image that helps licensed Broadcast
customers install and run Broadcast from Docker.

It is not a public Broadcast application image. It does **not** contain Broadcast
source code, binaries, license keys, registry credentials, or any other
proprietary Broadcast artifact.

Instead, this image works like a Dockerized version of the public Broadcast
installer:

1. You provide your own Broadcast license key and installation domain at runtime.
2. The launcher validates the license with Broadcast.
3. Broadcast returns registry credentials for your licensed account.
4. The launcher logs in to Broadcast's registry from your Docker host.
5. The launcher starts the official Broadcast app, job, and PostgreSQL containers
   with Docker Compose.

## Relationship with Broadcast

Quave is not affiliated with, endorsed by, sponsored by, or partnered with
Broadcast or Furvur Inc.

Broadcast is proprietary self-hosted software. Before using this image, you must
have a valid Broadcast license and must follow Broadcast's terms, including the
allowed number of servers and allowed hosting locations.

Relevant Broadcast links:

- Installation guide: <https://sendbroadcast.net/installation>
- Terms: <https://sendbroadcast.net/terms>

## What this image does not do

This image does not:

- redistribute Broadcast software;
- include a Broadcast license key;
- include Broadcast registry credentials;
- bypass Broadcast license checks;
- modify Broadcast application code;
- replace Broadcast support or documentation.

## Requirements

You need:

1. A valid Broadcast license.
2. A primary domain, for example `broadcast.example.com`.
3. A Docker host reachable by that domain.
4. The Docker socket mounted into the launcher container.
5. A host bind mount at the same path used by `BROADCAST_DATA_DIR` (default: `/opt/broadcast`).

The launcher uses the Docker socket to start sibling containers on the Docker
host, the same way a host-level installer would use Docker Compose. Because bind
mounts are created by the host Docker daemon, mount the host data directory into
the launcher at the same absolute path. It is meant for Docker hosts. It is not
meant to run as a nested app container on platforms that do not expose a Docker
socket.

## Install

Point the domain to your Docker host first, then run:

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/broadcast:/opt/broadcast \
  -e BROADCAST_DOMAIN="broadcast.example.com" \
  -e BROADCAST_LICENSE_KEY="xxxxx-xxxxx-xxxxx-xx" \
  zcloudws/broadcast:1.0.0 install
```

The launcher stores generated config, PostgreSQL data, uploads, logs, and TLS
state under `/opt/broadcast` by default.

Open the app at:

```text
https://broadcast.example.com
```

## Choose a Broadcast version

By default, the launcher starts Broadcast `latest`. To pin a Broadcast version,
set `BROADCAST_VERSION`:

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/broadcast:/opt/broadcast \
  -e BROADCAST_DOMAIN="broadcast.example.com" \
  -e BROADCAST_LICENSE_KEY="xxxxx-xxxxx-xxxxx-xx" \
  -e BROADCAST_VERSION="2.0.0" \
  zcloudws/broadcast:1.0.0 install
```

If Broadcast gives you a full image reference, you can use `BROADCAST_IMAGE`
instead. It overrides `BROADCAST_VERSION`:

```bash
-e BROADCAST_IMAGE="gitea.hostedapp.org/broadcast/broadcast:2.0.0"
```

## Ports

By default, Broadcast binds host ports `80` and `443`.

Override them if necessary:

```bash
-e BROADCAST_HTTP_PORT="8080" \
-e BROADCAST_HTTPS_PORT="8443"
```

## Status, logs, and stop

Use the same volume and project name when running management commands:

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/broadcast:/opt/broadcast \
  zcloudws/broadcast:1.0.0 status

docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/broadcast:/opt/broadcast \
  zcloudws/broadcast:1.0.0 logs

docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/broadcast:/opt/broadcast \
  zcloudws/broadcast:1.0.0 stop
```

## Environment variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `BROADCAST_DOMAIN` | Yes for `install` |  | Primary Broadcast domain. |
| `BROADCAST_LICENSE_KEY` | Yes for `install` |  | Customer's Broadcast license key. |
| `BROADCAST_VERSION` | No | `latest` | Official Broadcast version tag to run. |
| `BROADCAST_IMAGE` | No | Derived from license registry and version | Full official Broadcast image. Overrides `BROADCAST_VERSION`. |
| `BROADCAST_DATA_DIR` | No | `/opt/broadcast` | Host data/config directory. Mount the same host path into the launcher. |
| `BROADCAST_PROJECT_NAME` | No | `broadcast` | Docker Compose project name. |
| `BROADCAST_HTTP_PORT` | No | `80` | Host HTTP port. |
| `BROADCAST_HTTPS_PORT` | No | `443` | Host HTTPS port. |
| `BROADCAST_POSTGRES_PORT` | No | `127.0.0.1:5432` | Host bind for PostgreSQL. |

## Build this public launcher image

Project members can publish the launcher through this repository's `Publish
images` GitHub Action:

- Image: `broadcast`
- Image version: for example `1.0.0`

Equivalent local commands:

```bash
cd broadcast
./build.sh 1.0.0
./push.sh 1.0.0
```

Publishing `zcloudws/broadcast:<version>` publishes only the launcher. It does
not publish Broadcast itself.

## Deploy with Quave ONE MCP

Use this prompt when you want an agent to create a Docker-host app or equivalent
customer environment around this launcher:

```text
Use Quave ONE MCP to deploy the public Quave Broadcast Docker launcher.

Important constraints:
- Quave is not affiliated with Broadcast or Furvur Inc.
- The customer has a valid Broadcast license.
- The public image zcloudws/broadcast:<VERSION> does not contain Broadcast software.
- The launcher needs Docker socket access on the target Docker host because it starts Broadcast sibling containers with Docker Compose.
- Confirm the selected region is allowed by the customer's Broadcast license.

Deployment details:
- Customer/account: CUSTOMER_ACCOUNT_NAME_OR_ID
- Domain: broadcast.example.com
- Launcher image: zcloudws/broadcast:<VERSION>
- Required secrets:
  - BROADCAST_LICENSE_KEY=...
- Required env vars:
  - BROADCAST_DOMAIN=broadcast.example.com
  - BROADCAST_VERSION=latest, or a specific Broadcast version

Please create the customer deployment, configure secrets, run the launcher install command, monitor status/logs, and report the DNS record the customer must create.
```
