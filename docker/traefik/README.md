# Traefik Container

## Description

This deployment runs Traefik in a single containers.


## Usage

First create a `traefik.env` file to substitute variables for your deployment.

### Traefik environment variables for interactig with Cloudflare DNS and LetsEncrypt

Example `traefik.env` file in the same directory as your `docker-compose.yml` file:

```
CLOUDFLARE_DNS_API_TOKEN=****
CLOUDFLARE_ZONE_API_TOKEN=****
```

### Running the container

```bash
docker compose up -d

#OR
podman compose up -d
```

Open your web browser on: http://<yourip>:8080

> If using Portainer, just paste the `docker-compose.yaml` contents into the stack config and add your *environment variables* directly in the UI.


Send Feedback