# Installation process

## Obtain a CrowdSec API token then add it to Kubernetes namespace cert-manager

On your home directory of your Linux host (please avoid root user), create your configuration files and Docker Compose stack:
```

CROWDSEC_API_KEY=yourkey_here
mkdir -p $HOME/crowdsec/config

cat <<EOF >$HOME/crowdsec/docker-compose.yml
version: '3.8'
services:
  crowdsec:
    image: crowdsecurity/crowdsec:latest
    container_name: crowdsec
    environment:
      GID: "${GID-1000}"
      COLLECTIONS: "crowdsecurity/linux crowdsecurity/traefik"
    # depends_on:  #uncomment if running traefik in the same compose file
    #   - 'traefik'
    volumes:
      - ${HOME}/crowdsec/config/acquis.yaml:/etc/crowdsec/acquis.yaml
      - crowdsec-db:/var/lib/crowdsec/data/
      - crowdsec-config:/etc/crowdsec/
      - traefik_logs:/var/log/traefik/:ro
    networks:
      - traefik_default
    restart: unless-stopped

  bouncer-traefik:
    image: docker.io/fbonalair/traefik-crowdsec-bouncer:latest
    container_name: bouncer-traefik
    environment:
      PORT: 8082
      CROWDSEC_BOUNCER_API_KEY: \$CROWDSEC_API_KEY
      CROWDSEC_AGENT_HOST: crowdsec:8080
    ports:
      - "8082:8080"
    networks:
      - traefik_default # same network as traefik + crowdsec
    depends_on:
      - crowdsec
    restart: unless-stopped

  whoami:
    image: traefik/whoami
    container_name: "simple-whoami-service"
    labels:
      # Traefik routing to this service
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host(`whoami-docker.home.techfitsu.org`)"
      - "traefik.http.routers.whoami.entrypoints=websecure"
      - "traefik.http.routers.whoami.middlewares=crowdsec-bouncer@file"
      - "traefik.http.services.whoami.loadbalancer.server.port=80"
      - "traefik.http.routers.whoami.service=whoami"
      - "traefik.http.routers.whoami.tls=true"
      - "traefik.http.routers.whoami.tls.certresolver=production"
    
    

networks:
  traefik_default:
    external: true
volumes:
  crowdsec-db:
  crowdsec-config:
  traefik_logs: # this will be the name of the volume from traefik logs
    external: true # remove if traefik is running on same stack
EOF


cat <<EOF >crowdsec/config/acquis.yml
filenames:
  - /var/log/traefik/*
labels:
  type: traefik

EOF

```


## Install Helm on the management station
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
# Check version
helm --version

cd kubernetes/traefik-cert-manager
```

## Install Cert-Manager using Helm
```

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.13.2 \
--values cert-manager/values.yaml
kubectl get pods --namespace cert-manager
```

## Alternatively install Cert-Manager using kubectl. Follow all available methods: https://cert-manager.io/docs/installation/
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
```


# Create the staging/production LetsEncrypt Cluster certificate issuers with Cloudflare as DNS01 challenge resolver.
```
kubectl apply -f cert-manager/issuers/letsencrypt-staging.yaml
kubectl apply -f cert-manager/issuers/letsencrypt-production.yaml
# Pull certs from staging instance. Should return with "No resources found in namespace"
kubectl get certificate
```

# Manually create one certificate using the LetsEncrypt staging issuer
If you want to dig deeper on the cert provisioning process, you can also check all the DNS or HTTP challenges that LetsEncrypt is going through to provide a valid certificate, by using kubectl get challenges.

```
kubectl apply -f cert-manager/certificates/staging/nginx-home.yaml

# Pull certs from staging instance. Now you should see is still not ready to be used.
kubectl get certificate -w

NAME         READY   SECRET                   AGE
nginx-home   False    nginx-home-staging-tls   76s

# See DNS or HTTP challenges.
kubectl get challenges -w
```

# Deploy you Nginx service with the ingress tls.secretName referencing the staging certificate "nginx-home-staging-tls".
```
kubectl apply -f nginx/deployment.yaml
kubectl apply -f nginx/service.yaml
kubectl apply -f nginx/ingress.yaml
```

# Open Traefik dashboard and also Nginx.
NOTE: do not forget to add the service FQDN to local DNS or on the network DNS. All the names below are just examples, feel free to adjust.
Local NGINX url https://nginx.yourdomain
Traefik Dashboard: https://traefik-k3s1.yourdomain

# Now manually deploy production certificate and use them on your ingress
```
kubectl apply -f cert-manager/certificates/production/nginx-home.yaml

Update the nginx ingress in order to change the tls.secretName to be "nginx-home-production-tls"
```


# The ultimate SSL certicate provisioning, using Certmanager Annotated Ingress Resource
Documentation: https://cert-manager.io/docs/usage/ingress/#supported-annotations
See an example on the nginx/ingress.yaml file

# Uninstalling cert-manager via Helm
Go to https://cert-manager.io/docs/installation/helm/#uninstalling


# References:
https://technotim.live/posts/kube-traefik-cert-manager-le/
https://github.com/JamesTurland/JimsGarage/blob/main/Kubernetes/Rancher-Deployment/readme.md