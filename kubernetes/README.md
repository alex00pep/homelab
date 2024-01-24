
# HomeLab - Kubernetes as container orchestration engine
The main goal to have K3s clusters on a considerable medium level, which includes resilency and security.

Design principles:
1. Simple to spin up and tear down.
2. Security-first approach with PodSecurity to allow for isolation and CrowdSec software to block malintentioned requests to the ingress objects.
3. Automated certificate management for all ingresses, with resilient certificate issuers.
4. Monitoring from the first day for all services and including the host.


## Resilient SSL certificate management
Go to subfolder traefik-cert-manager and follow instructions.

## Monitoring
Check the monitoring subfolder and follow installation procedure.

