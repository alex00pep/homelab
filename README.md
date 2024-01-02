# homelab
My home lab documentation is based on Docker (containerd as container runtime) as container engine. For Other parts of my lab, Kubernetes will be highly used.

## Usage
### Docker-based lab installation: 
First, install Docker Desktop or Docker engine and client each Linux host you need. Then start the Traefik and Portainer stacks (Server and Agent), in that order. Each Portainer agent should be started on its own container on separate host from server.

Make sure to also install Traefik on every host that will run HTTP/HTTPS services using containers.
All the other container stacks should be started in this order:
1. Pihole
2. MeshCentral
3. NetBootXYZ


You can start all the three above container stacks using Portainer Server UI:

https://portainer.home.techfitsu.org


###  For Kubernetes-based lab installation
More to come