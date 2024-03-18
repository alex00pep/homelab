# Install Helm on the management station
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
# Check version
helm --version

cd kubernetes/
```

# Install Prometheus Community repo and create a monitoring namespace
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring

```

# Create secrets for Grafana dashboard login
Change the user and password according to your needs
```
echo -n 'admin' > ./admin-user # change your username
echo -n 'yourpass' > ./admin-password # change your password
kubectl  -n monitoring create secret generic grafana-admin-credentials --from-file=./admin-user --from-file=admin-password
# Verify secrets
kubectl describe secret -n monitoring grafana-admin-credentials
kubectl get secret -n monitoring grafana-admin-credentials -o jsonpath="{.data.admin-user}" | base64 --decode
kubectl get secret -n monitoring grafana-admin-credentials -o jsonpath="{.data.admin-password}" | base64 --decode
# Delete the local secrets
rm admin-user && rm admin-password

```

# Create/Update your kube-prometheus-stack
Source URL: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
```
helm install -n monitoring prometheus prometheus-community/kube-prometheus-stack -f monitoring/values.yaml
```

If you make changes to your values.yaml you can deploy these changes by running
```
helm upgrade -n monitoring prometheus prometheus-community/kube-prometheus-stack -f monitoring/values.yaml
```

You should receive an output similar to this:
```
Release "prometheus" has been upgraded. Happy Helming!
NAME: prometheus
LAST DEPLOYED: Wed Jan 24 02:44:25 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 2
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```
# Install Cert and Ingress for Grafana and Prometheus Alert Manager
```
kubectl -n monitoring apply -f cert-manager/certificates/production/home-production.yaml

# Pull certs from production issuer instance.
kubectl -n monitoring get certificate -w

kubectl -n monitoring apply -f monitoring/ingress.yaml
```

# Go to Traefik , Grafana and Alert Manager GUIs.
NOTE: do not forget to add the service FQDN to local DNS or on the network DNS. All the names below are just examples, feel free to adjust.
Local Grafana url https://grafana-*.yourdomain


# Unstalling monitoring stack
```
helm uninstall -n monitoring prometheus
kubectl delete namespace monitoring
```

# References:
https://technotim.live/posts/kube-grafana-prometheus/