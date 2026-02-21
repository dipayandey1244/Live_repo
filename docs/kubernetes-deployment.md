# Step-by-step: deploy this repo on Kubernetes

Yes — this repo architecture (UI + Python regression backend) can be deployed live on Kubernetes and safely updated over time.

## Step 1: Confirm prerequisites

- You have a Kubernetes cluster (EKS/GKE/AKS/minikube/kind).
- `kubectl` is installed and connected to the cluster.
- Docker (or another image builder) is installed.
- You have push access to a container registry.

Check quickly:

```bash
kubectl cluster-info
docker --version
```

## Step 2: Choose your registry and release tag

Use immutable tags (example: git SHA):

```bash
export REGISTRY=ghcr.io/<org>
export TAG=$(git rev-parse --short HEAD)
```

## Step 3: Build and push backend image

```bash
docker build -t ${REGISTRY}/regression-backend:${TAG} backend/
docker push ${REGISTRY}/regression-backend:${TAG}
```

## Step 4: Build and push UI image

```bash
docker build -t ${REGISTRY}/regression-ui:${TAG} ui/
docker push ${REGISTRY}/regression-ui:${TAG}
```

## Step 5: Deploy with one command

Run the helper script:

```bash
REGISTRY=${REGISTRY} TAG=${TAG} ./k8s/deploy.sh
```

This will create namespace `regression`, apply manifests, set image tags, and wait for rollout.

## Step 6: Verify pods and services

```bash
kubectl -n regression get pods
kubectl -n regression get svc
kubectl -n regression logs deploy/regression-backend --tail=100
```

## Step 7: Open the UI

- Cloud cluster: get external IP from `kubectl -n regression get svc regression-ui`.
- Local cluster: port-forward:

```bash
kubectl -n regression port-forward svc/regression-ui 8080:80
```

Then open `http://localhost:8080`.

## Step 8: Run regression checks and view results

- Trigger your backend regression endpoint/job flow.
- Verify results appear in UI.

## Step 9: Update code and redeploy

When any of the four `.py` assumption files or UI code changes:

1. Commit changes.
2. Build/push new image tags.
3. Re-run deployment with new tag.
4. Trigger a new regression run.
5. Compare old vs new output in UI.

Example:

```bash
export TAG=$(git rev-parse --short HEAD)
REGISTRY=${REGISTRY} TAG=${TAG} ./k8s/deploy.sh
```

## Step 10: Production best practices

- Keep results/state in DB/object storage, not pod local disk.
- Keep staging and production namespaces.
- Add CI/CD to build, test, and deploy.
- Track each run with metadata (`git_sha`, assumptions version, timestamp).
