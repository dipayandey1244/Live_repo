## Summary
- What changed and why.

## Merge checklist
- [ ] CI is green (syntax + YAML validation).
- [ ] `k8s/deploy.sh` still works with `REGISTRY` + `TAG`.
- [ ] Deployment docs are updated if commands/flow changed.
- [ ] No `:latest` usage in release commands.
- [ ] Rollout verification commands are included (`kubectl rollout status ...`).

## Deployment smoke steps (copy/paste)
```bash
export REGISTRY=ghcr.io/<org>
export TAG=$(git rev-parse --short HEAD)
REGISTRY=${REGISTRY} TAG=${TAG} ./k8s/deploy.sh
kubectl -n regression get pods
kubectl -n regression get svc
```
