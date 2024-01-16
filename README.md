# homelab
My home lab documentation is based on Docker (containerd as container runtime) as container engine. For Other parts of my lab, Kubernetes will be highly used.

## Usage
### Docker-based lab installation: 
First, install Docker Desktop or Docker engine (for Linux systems) and Docker Compose on host you need. Establish SSH key-based authentication for all hosts. Each Portainer agent should be started on its own container on separate agent host from server. This can be done using Ansible playbook. If you have Raspberry Pi devices, this is applicable as well.

Docker installation playbook [https://github.com/Gatsby-Lee/moon-rapi/blob/main/ansible_playbook/install-docker-on-rpios-bookworm.yaml]



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

### Install Docker host monitoring stacks
This is optional. but if you need it you can do it.
The monitoring solutions includes:
1. 

### Continuing homelab setup
All the other container stacks should be started in this order:
1. Pihole+unbound (using a Raspberry Pi) - DNS and DNSSEC and improved DNS privacy using Unbound
2. MeshCentral - Manage bare metal server installation using Intel ATM capable devices like Dell Optiplex 7050 with vPro tagging.
3. NetBootXYZ - Menu-based TFP server for bare metal installations with pxe and netboot environments inventory.
3. Prometheus-Grafana-NodeExporter-CAdvisor - Monitoring and alerting


You can start all the three above container stacks using Portainer Server UI:

https://portainer.home.techfitsu.org


###  For Kubernetes-based lab installation
More to come