
# HomeLab - Kubernetes as container orchestration engine
The main goal to have K3s clusters on a considerable medium level, which includes resilency and security.

Design principles:
1. Simple to spin up and tear down.
1. Security-first approach with PodSecurity to allow for isolation and CrowdSec software to block malintentioned requests to the ingress objects.
2. Automated certificate management for all ingresses, with resilient certificate issuers.


## Certificate management build

Go to subfolder traefik-cert-manager and follow instructions.