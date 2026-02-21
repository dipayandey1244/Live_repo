# Kubernetes manifests + deployment guide

This folder contains starter manifests and a helper script for running the UI + regression backend in Kubernetes.

## Quick step-by-step deploy

### Step 1) Set variables

```bash
export REGISTRY=ghcr.io/<org>
export TAG=$(git rev-parse --short HEAD)
```

### Step 2) Build + push images

```bash
# example only: adjust build contexts to your repo layout
docker build -t ${REGISTRY}/regression-backend:${TAG} backend/
docker push ${REGISTRY}/regression-backend:${TAG}

docker build -t ${REGISTRY}/regression-ui:${TAG} ui/
docker push ${REGISTRY}/regression-ui:${TAG}
```

### Step 3) Deploy

```bash
REGISTRY=${REGISTRY} TAG=${TAG} ./k8s/deploy.sh
```

### Step 4) Verify

```bash
kubectl -n regression get pods
kubectl -n regression get svc
kubectl -n regression logs deploy/regression-backend --tail=100
```

### Step 5) Open UI

```bash
kubectl -n regression port-forward svc/regression-ui 8080:80
# open http://localhost:8080
```

### Step 6) Redeploy updates

```bash
export TAG=$(git rev-parse --short HEAD)
REGISTRY=${REGISTRY} TAG=${TAG} ./k8s/deploy.sh
```

---

## Prerequisites

- Kubernetes cluster available (EKS/GKE/AKS/minikube/kind).
- `kubectl` configured against that cluster.
- Image registry access.

## Manual deployment (without script)

```bash
kubectl create namespace regression --dry-run=client -o yaml | kubectl apply -f -
kubectl -n regression apply -f k8s/backend-deployment.yaml
kubectl -n regression apply -f k8s/ui-deployment.yaml

kubectl -n regression set image deployment/regression-backend \
  backend=${REGISTRY}/regression-backend:${TAG}
kubectl -n regression set image deployment/regression-ui \
  ui=${REGISTRY}/regression-ui:${TAG}

kubectl -n regression rollout status deployment/regression-backend
kubectl -n regression rollout status deployment/regression-ui
```
