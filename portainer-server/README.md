# Portainer and Traefik - 2 Container

## Description

This Docker deployment runs both Portainer and Traefik in two individual ontainers.


## Usage

First create a `.env` file to substitute variables for your deployment.

### Traefik environment variables for interactig with Cloudflare DNS and LetsEncrypt

Example `.env` file in the same directory as your `docker-compose.yml` file:

```
CLOUDFLARE_DNS_API_TOKEN=****
CLOUDFLARE_ZONE_API_TOKEN=****
```

### Running the stack using Portainer UI

```bash
docker-compose up -d
```

> If using Portainer, just paste the `docker-compose.yaml` contents into the stack config and add your *environment variables* directly in the UI.

0 VINs found



View Showroom
0 VINs identified


Send Feedback