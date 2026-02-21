#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   REGISTRY=ghcr.io/acme \
#   TAG=$(git rev-parse --short HEAD) \
#   ./k8s/deploy.sh
#
# Optional env vars:
#   NAMESPACE=regression
#   BACKEND_IMAGE=ghcr.io/acme/regression-backend
#   UI_IMAGE=ghcr.io/acme/regression-ui

NAMESPACE="${NAMESPACE:-regression}"
TAG="${TAG:-latest}"
BACKEND_IMAGE="${BACKEND_IMAGE:-${REGISTRY:-registry.example.com}/regression-backend}"
UI_IMAGE="${UI_IMAGE:-${REGISTRY:-registry.example.com}/regression-ui}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERROR: kubectl is required but not installed." >&2
  exit 1
fi

echo "[1/4] Ensuring namespace '${NAMESPACE}' exists"
kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${NAMESPACE}"

echo "[2/4] Applying manifests"
kubectl -n "${NAMESPACE}" apply -f k8s/backend-deployment.yaml
kubectl -n "${NAMESPACE}" apply -f k8s/ui-deployment.yaml

echo "[3/4] Updating images"
kubectl -n "${NAMESPACE}" set image deployment/regression-backend backend="${BACKEND_IMAGE}:${TAG}"
kubectl -n "${NAMESPACE}" set image deployment/regression-ui ui="${UI_IMAGE}:${TAG}"

echo "[4/4] Waiting for rollout"
kubectl -n "${NAMESPACE}" rollout status deployment/regression-backend
kubectl -n "${NAMESPACE}" rollout status deployment/regression-ui

echo "Done. Services in namespace '${NAMESPACE}':"
kubectl -n "${NAMESPACE}" get svc
