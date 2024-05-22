

# Installing latest/stable version of ArgoCD

## (Recommended) Using Helm charts with SSL Termination at Ingress controller
```

cat <<'EOF' > argocd-values.yaml
global:
  domain: <your-argocd-fqdn>

certificate:
  enabled: false

configs:
  params:
    server.insecure: true

server:
  ingress:
    enabled: true
    ingressClassName: <traefik/nginx/contour-internal>
    annotations:
      cert-manager.io/cluster-issuer: "<your-issuer>"
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"

    # -- Enable TLS configuration for the hostname defined at `server.ingress.hostname`
    ## TLS certificate will be retrieved from a TLS secret `argocd-server-tls`
    ## You can create this secret via `certificate` or `certificateSecret` option
    tls: false

    extraTls:
      - hosts:
        - <your-argocd-fqdn>
        # Based on the secret used for the current ingress controller, might be optional
        secretName: <your-cert-secret-name>
EOF

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install/upgrade argocd argo/argo-cd --namespace argocd --create-namespace -f argocd-values.yaml
```
## Using Kubernetes manifests
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```


## Checking ArgoCD installation
```
kubectl get pods -n argocd
kubectl get services -n argocd
```
## Forward ArgoCD Ports (Not needed if installed Helm chart above)
```
kubectl get services -n argocd
kubectl port-forward service/argocd-server -n argocd 8080:443
```

## Get ArgoCD Credentials
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

# Install ArgoCD CLI / Login via CLI
```
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

argocd login 127.0.0.1:8080
```

# Installing Argo-Rollouts

## Standard installation method, using Helm charts
```

cat <<'EOF' > argo-rollouts-values.yaml
dashboard:
  # -- Deploy dashboard server
  enabled: true
  ingress:
    # -- Enable dashboard ingress support
    enabled: true
    # -- Dashboard ingress class name
    ingressClassName: "traefik/nginx"
    annotations:
      cert-manager.io/cluster-issuer: "<your-issuer>"
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"

    # -- Enable Dashboard TLS configuration 
    ## TLS certificate will be retrieved from a TLS secret
    ## You can create this secret via `certificate` or `certificateSecret` option
    tls:
      - secretName: argorollouts-example-tls
        hosts:
          - argorollouts.example.com

EOF

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argo-rollouts argo/argo-rollouts --namespace argo-rollouts --create-namespace -f argo-rollouts-values.yaml
```
## Standard installation metho, using Kubernetes manifests
```
kubectl create namespace argo-rollout
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

# Creating an Application using ArgoCD CLI:
```
argocd app create webapp-kustom-prod \
--repo https://github.com/devopsjourney1/argo-examples.git \
--path kustom-webapp/overlays/prod --dest-server https://kubernetes.default.svc \
--dest-namespace prod
```

# Command Cheat sheet
```
argocd app create #Create a new Argo CD application.
argocd app list #List all applications in Argo CD.
argocd app logs <appname> #Get the application’s log output.
argocd app get <appname> #Get information about an Argo CD application.
argocd app diff <appname> #Compare the application’s configuration to its source repository.
argocd app sync <appname> #Synchronize the application with its source repository.
argocd app history <appname> #Get information about an Argo CD application.
argocd app rollback <appname> #Rollback to a previous version
argocd app set <appname> #Set the application’s configuration.
argocd app delete <appname> #Delete an Argo CD application.
```





