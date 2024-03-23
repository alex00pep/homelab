# Cert-Manager and Traefik for SSL protection - Installation process

## Install/Configure Helm on the management station
```

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm ./get_helm.sh


kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
cd kubernetes/traefik-cert-manager
```

## Install Cert-Manager and Reflector using Helm
```
# You might need to add a few CRD's. If you see following error, unable to recognize "": no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1.
kubectl create -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml

helm upgrade --install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.14.4 \
--values cert-manager/values.yaml
kubectl get pods --namespace cert-manager
helm upgrade --install reflector emberstack/reflector \
 --create-namespace \
 --namespace reflector
kubectl get pods --namespace reflector
```

### Alternatively install Cert-Manager using kubectl. Follow all available methods: https://cert-manager.io/docs/installation/
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
```
## Obtain a Cloudflare API token then add it to Kubernetes namespace cert-manager

```
cp secrets/sample-secret-cf-token.yaml secrets/secret-cf-token.yaml
# Edit your file secrets/secret-cf-token.yaml to add your Cloudflare API token, before running cmd below

kubectl apply -f secrets/secret-cf-token.yaml
```

## Create the staging/production LetsEncrypt certificate issuers with Cloudflare DNS01 challenge resolver.
```
kubectl apply -f cert-manager/issuers/letsencrypt-staging.yaml
kubectl apply -f cert-manager/issuers/letsencrypt-production.yaml
# Pull certs from staging instance. Should return with "No resources found in namespace"
kubectl get certificate
```


## Add Traefik Dashboard
```
# Generate user and password for dashboard and paste it into traefik/dashboard/secret-dashboard.yaml
PASSWORD=$(htpasswd -nb admin recallsvnxe3rk6sz | openssl base64)
REGION=nane02

cp traefik/dashboard/ingress-template.yaml traefik/dashboard/ingress.yaml
cp traefik/dashboard/secret-template.yaml traefik/dashboard/secret.yaml

sed -i -e "s/\$REGION/$REGION/g" traefik/dashboard/ingress.yaml
sed -i -e "s/\$PASSWORD/$PASSWORD/g" traefik/dashboard/secret.yaml
kubectl apply -f traefik/dashboard/secret.yaml
kubectl apply -f traefik/dashboard/middleware.yaml
kubectl apply -f traefik/default-headers.yaml
kubectl apply -f traefik/dashboard/ingress.yaml
```

## Create a Traefik production certificate manually
If you want to dig deeper on the cert provisioning process, you can also check all the DNS or HTTP challenges that LetsEncrypt is going through to provide a valid certificate, by using kubectl get challenges.

```

# Now manually deploy production certificate and use them on your ingress
kubectl -n kube-system apply -f cert-manager/certificates/production/home-production.yaml

# Pull certs from staging instance. Now you should see is still not ready to be used.
kubectl get certificate -w

NAME         READY   SECRET                   AGE
home-production-tls   False    home-production-tls   76s

# See DNS or HTTP challenges.
kubectl get challenges -w

#Update the nginx ingress in order to change the tls.secretName to be "home-production-tls"

```

## Deploy your Nginx and Whoami services with ingress provisioning.
```
cp nginx/ingress-template.yaml nginx/ingress.yaml
REGION=nane01
sed -i -e "s/\$REGION/$REGION/g" nginx/ingress.yaml

kubectl -n default apply -f nginx/deployment.yaml
kubectl -n default apply -f nginx/service.yaml
kubectl -n default apply -f nginx/ingress.yaml
```

# Open Traefik dashboard and also Nginx.
NOTE: do not forget to add the service FQDN to local DNS or on the network DNS. All the names below are just examples, feel free to adjust.

Local NGINX url https://nginx.yourdomain

Traefik Dashboard: https://traefik-.yourdomain

Whoami service: https://whoami.yourdomain



## Delete Traefik in case is needed
```
kubectl -n kube-system delete helmcharts.helm.cattle.io traefik --force
helm uninstall traefik traefik-crd -n kube-system 
# On the master nodes run these commands:
sudo rm -rf /var/lib/rancher/k3s/server/manifests/traefik.yaml
sudo systemctl restart k3s
```


# The ultimate SSL certicate provisioning, using Certmanager Annotated Ingress Resource
Documentation: https://cert-manager.io/docs/usage/ingress/#supported-annotations
See an example on the nginx/ingress.yaml file

# Uninstalling cert-manager via Helm
Go to https://cert-manager.io/docs/installation/helm/#uninstalling


# References:
https://technotim.live/posts/kube-traefik-cert-manager-le/
https://github.com/JamesTurland/JimsGarage/blob/main/Kubernetes/Rancher-Deployment/readme.md