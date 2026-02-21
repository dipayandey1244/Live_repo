# Kubernetes rollout plan for this repo

Yes — you can put this project live on Kubernetes and keep updating it safely.

## Deployment model

1. **Containerize the UI and backend**
   - Build one image for the UI service (frontend/web server).
   - Build one image for the Python regression backend.
2. **Deploy with Kubernetes Deployments + Services**
   - Use a Deployment per service for rolling updates.
   - Expose services with ClusterIP internally, and Ingress/LoadBalancer for external traffic.
3. **Persist assumptions/results if needed**
   - If generated results must survive restarts, write to a DB/object store.
   - Avoid storing important runtime state only on pod local disk.

## Update workflow (active repo)

For every code update:

1. Commit to this repo.
2. Build and push new image tags.
3. Update the Deployment image (or let GitOps do it).
4. Kubernetes performs a rolling update.
5. Re-run regression jobs and verify new results in the UI.

## Safe re-run pattern for updated code

- Trigger recalculation through a dedicated endpoint/job queue.
- Store each run with a version field (`git_sha`, model version, assumptions file set).
- Show run history in UI so users can compare old vs updated output.

## Recommended production checks

- Health probes (`/healthz`, `/readyz`) for backend and UI.
- Resource requests/limits to prevent noisy-neighbor issues.
- Horizontal Pod Autoscaler if load varies.
- CI pipeline that runs tests before image publish.
- Staging namespace for pre-production validation.

## Minimal command flow

```bash
# build + push
# docker build -t registry.example.com/regression-backend:<tag> backend/
# docker push registry.example.com/regression-backend:<tag>

# apply manifests
kubectl apply -f k8s/

# rollout update
kubectl set image deployment/regression-backend \
  backend=registry.example.com/regression-backend:<new-tag>

# verify
kubectl rollout status deployment/regression-backend
```

## Bottom line

Your described architecture (UI + backend regression code) is a good fit for Kubernetes. It supports going live, rolling updates, and repeated reruns of updated code as long as result versioning and state persistence are handled intentionally.
