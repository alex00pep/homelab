# Install Helm on the management station
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
# Check version
helm --version
rm -rf get_helm.sh
cd kubernetes/
```

# Prerequisites
## Install Cert-Manager


# Add Rancher repo and install Rancher
```
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
kubectl create ns cattle-system
cp rancher/values-template.yaml rancher/values.yaml
REGION=nane02
PASSWORD=yourpass
sed -i -e "s/\$REGION/$REGION/g" rancher/values.yaml
sed -i -e "s/\$PASSWORD/$PASSWORD/g" rancher/values.yaml
helm install rancher rancher-latest/rancher --version 2.8.2  --namespace cattle-system --create-namespace  --values=rancher/values.yaml
sleep 300
echo https://rancher-${REGION}.home.techfitsu.org/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')

```

Browse to the provided URL in the last command output

Happy Ranching!!!