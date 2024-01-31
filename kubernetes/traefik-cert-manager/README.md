# Cert-Manager and Traefik for SSL protection - Installation process

## Install/Configure Helm on the management station
```
cd kubernetes
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm ./get_helm.sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
cd traefik-cert-manager
```

## Install Cert-Manager and Reflector using Helm
```
# You might need to add a few CRD's. If you see following error, unable to recognize "": no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1.
kubectl create -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml

helm upgrade --install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.13.2 \
--values cert-manager/values.yaml
kubectl get pods --namespace cert-manager
helm upgrade --install reflector emberstack/reflector \
 --create-namespace \
 --namespace reflector
kubectl get pods --namespace reflector
```

### Alternatively install Cert-Manager using kubectl. Follow all available methods: https://cert-manager.io/docs/installation/
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
```
## Obtain a Cloudflare API token then add it to Kubernetes namespace cert-manager

```
cp secrets/sample-secret-cf-token.yaml secrets/secret-cf-token.yaml
# Edit your file secrets/secret-cf-token.yaml to add your Cloudflare API token, before running cmd below

kubectl apply -f secrets/secret-cf-token.yaml
```

## Create the staging/production LetsEncrypt Cluster certificate issuers with Cloudflare as DNS01 challenge resolver.
```
kubectl apply -f cert-manager/issuers/letsencrypt-staging.yaml
kubectl apply -f cert-manager/issuers/letsencrypt-production.yaml
# Pull certs from staging instance. Should return with "No resources found in namespace"
kubectl get certificate
```


## Add Traefik Dashboard
```
# Generate user and password for dashboard and paste it into traefik//dashboard/secret-dashboard.yaml
htpasswd -nb admin password | openssl base64

kubectl apply -f traefik//dashboard/secret-dashboard.yaml
kubectl apply -f traefik/dashboard/middleware.yaml
kubectl apply -f traefik/dashboard/ingress.yaml
kubectl apply -f traefik/default-headers.yaml
```

## Delete Traefik in case is needed
```
kubectl -n kube-system delete helmcharts.helm.cattle.io traefik --force
helm uninstall traefik traefik-crd -n kube-system 
# On the master nodes run these commands:
sudo rm -rf /var/lib/rancher/k3s/server/manifests/traefik.yaml
sudo systemctl restart k3s
```

## [Optional] Create a staging certificate manually
If you want to dig deeper on the cert provisioning process, you can also check all the DNS or HTTP challenges that LetsEncrypt is going through to provide a valid certificate, by using kubectl get challenges.

```
kubectl apply -f cert-manager/certificates/staging/nginx-home.yaml

# Pull certs from staging instance. Now you should see is still not ready to be used.
kubectl get certificate -w

NAME         READY   SECRET                   AGE
nginx-home   False    nginx-home-staging-tls   76s

# See DNS or HTTP challenges.
kubectl get challenges -w
# Now manually deploy production certificate and use them on your ingress
kubectl apply -f cert-manager/certificates/production/nginx-home.yaml
#Update the nginx ingress in order to change the tls.secretName to be "nginx-home-staging-tls"

```

## Deploy your Nginx and Whoami service with automatic certificate and ingress provisioning.
```
kubectl apply -f nginx/deployment.yaml
kubectl apply -f nginx/service.yaml
kubectl apply -f nginx/ingress.yaml
```

# Open Traefik dashboard and also Nginx.
NOTE: do not forget to add the service FQDN to local DNS or on the network DNS. All the names below are just examples, feel free to adjust.

Local NGINX url https://nginx.yourdomain

Traefik Dashboard: https://traefik-k3s1.yourdomain

Whoami service: https://whoami.yourdomain




# The ultimate SSL certicate provisioning, using Certmanager Annotated Ingress Resource
Documentation: https://cert-manager.io/docs/usage/ingress/#supported-annotations
See an example on the nginx/ingress.yaml file

# Uninstalling cert-manager via Helm
Go to https://cert-manager.io/docs/installation/helm/#uninstalling


# References:
https://technotim.live/posts/kube-traefik-cert-manager-le/
https://github.com/JamesTurland/JimsGarage/blob/main/Kubernetes/Rancher-Deployment/readme.md