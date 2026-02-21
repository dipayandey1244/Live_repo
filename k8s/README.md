# Kubernetes manifests

This folder contains starter manifests for running the UI + regression backend in Kubernetes.

## Files

- `backend-deployment.yaml` — backend Deployment and ClusterIP Service.
- `ui-deployment.yaml` — UI Deployment and external Service.

## Apply

```bash
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/ui-deployment.yaml
```

## Update image tags

Replace `:latest` with immutable tags in production and use rolling updates:

```bash
kubectl set image deployment/regression-backend \
  backend=registry.example.com/regression-backend:<new-tag>
kubectl set image deployment/regression-ui \
  ui=registry.example.com/regression-ui:<new-tag>
```
