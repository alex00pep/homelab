#!/bin/bash


helm repo add traefik https://helm.traefik.io/traefik
helm repo update
kubectl create ns traefik
helm install traefik traefik/traefik -n traefik --values values.yaml