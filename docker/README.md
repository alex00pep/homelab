## Docker-based installation

First, install Docker Desktop or Docker engine (for Linux systems) and Docker Compose on host you need. Establish SSH key-based authentication for all hosts. Each Portainer agent should be started on its own container on separate agent host from server. This can be done using Ansible playbook. If you have Raspberry Pi devices, this is applicable as well.

Docker installation playbook [https://github.com/Gatsby-Lee/moon-rapi/blob/main/ansible_playbook/install-docker-on-rpios-bookworm.yaml]

## Add the Portainer server record to your home router DNS or install Pihole 

You can install Pihole and use it on your workstation as DNS resolver. To install please follow guidlines under docker/pihole folder.

### Installation of Portainer Server
SSH into to Portainer server host and start the Traefik and Portainer server stacks.

```bash
cd docker-compose/traefik
docker compose up -d
cd docker-compose/portainer-server
docker compose up -d
```

### Install Portainer Agent to all your agent nodes running Docker

```bash
cd docker-compose/portainer-agent
docker compose up -d
```

Open Portainer server UI on your web browser and check if you can see your agent nodes

https://portainer.home.techfitsu.org  # Replace with your own domain name and hostname


NOTE: You can start all container stacks below using Portainer Server UI

### Install Docker host monitoring stack
This is optional, but if you need it you can do it.

Make sure you have a user with UID 1000 and GID 1000, because the monitoring stack will run as that user. Also create the folder structure under the user home directory:

```bash
cd $HOME
mkdir -p promgrafnode/prometheus && mkdir -p promgrafnode/grafana/provisioning && touch promgrafnode/docker-compose.yml && touch promgrafnode/prometheus/prometheus.yml
```

The monitoring solutions includes:
1. Node-Exporter
2. Prometheus
3. Grafana
4. CAdvisor

```bash
cd docker-compose/promgrafnodecadvisor
docker compose up -d
```

Access Prometheus and Grafana on port 9090 and 3001 respectively, or via its DNS name and Traefik as Reverse Proxy.

https://prometheus.home.techfitsu.org

https://grafana.home.techfitsu.org


Add your CAdvisor and Node-Exporter dashboards to Grafana, using the "Import Dashboard" feature in the web UI.

1. Node-Exporter dashboard id: 12242
2. CAdvisor dashboard id: 14282


