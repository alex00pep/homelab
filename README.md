# HomeLab - Docker-based and Kubernetes lab setup
My home lab documentation is based on Docker (containerd as container runtime) as container engine. For Other parts of my lab, Kubernetes will be highly used.

## Prerequisites:

Obtain a domain name from a registrar and configure it on your DNS provider.
Cloudflare is both a registrar and provider, so is recommended. Also they have high availability across the globe on a free tier. The domain cost may vary depending on the registrar your choose, but the cost per year is around ~10 USD at the time of writing.

## For base infrastructure services follow the following sections:

- Docker standalone or Swarm mode please follow README file instructions under docker folder.

- For Kubernetes-based lab installation
More to come


## Continuing homelab setup (all this can be installed using Portainer UI)
All the other container stacks should be started in this order:
1. MeshCentral: Bare metal server installation using Intel AMT capable devices.
2. NetBootXYZ: Menu-based TFP server for bare metal installations with pxe and netboot environments inventory.
3. Prometheus-Grafana-NodeExporter-CAdvisor: Monitoring and alerting
