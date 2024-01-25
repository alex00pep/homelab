# Installation of toolchain
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

## Alternatively nstall Cert Manager using kubectl. Follow all available methods: https://cert-manager.io/docs/installation/
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
```


# Create the staging and production LetsEncrypt certificate issuers of type Cluster Issuer
```
kubectl apply -f cert-manager/issuers/secret-cf-token.yaml
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
