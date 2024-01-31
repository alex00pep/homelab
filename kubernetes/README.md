
# HomeLab - Services based on Kubernetes as container orchestration engine
The main goal to have K3s clusters on a considerable medium level, which includes resilency and security.

Design principles:
1. Simple to spin up and tear down.
2. Security-first approach with NetworkSecurityPolicies to allow for isolation and CrowdSec software to block malintentioned requests to the ingress objects.
3. Automated certificate management for all ingresses, with resilient certificate issuers.
4. Monitoring from the first day for all services and including the host.

The Fully-Automated, etcd-backed db, High-Availability K3S  cluster install is super cool and is entirely thanks to @TechoTim, @Jeff Geerling and k3s-io/k3s-ansible repo.
https://technotim.live/posts/k3s-etcd-ansible/
https://github.com/techno-tim/k3s-ansible
https://github.com/k3s-io/k3s-ansible

## Proper deployment order:
### First SSL certificate management for Traefik as LoadBalancer Ingress Controller
Go to subfolder traefik-cert-manager and follow instructions.


### Second: Monitoring
Check the monitoring subfolder and follow installation procedure.

