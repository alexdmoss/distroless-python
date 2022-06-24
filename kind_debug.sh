#!/usr/bin/env bash
set -ouE pipefail

curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

CLUSTER=distroless-test-$(( RANDOM%100000 ))

echo "DEBUG: create cluster"
kind create cluster --name="${CLUSTER}" --wait=60s

echo "DEBUG: list clusters"
kind get clusters

echo "DEBUG: cluster context"
cat /root/.kube/config

echo "DEBUG: get cluster info"
kubectl cluster-info --context ${CLUSTER}

echo "DEBUG: get cluster info (kind*)"
kubectl cluster-info --context kind-${CLUSTER}

echo "DEBUG: get namespaces"
kubectl get ns --context ${CLUSTER}

echo "DEBUG: get namespaces (kind*)"
kubectl get ns --context kind-${CLUSTER}

# # believe it or not this seems easier than getting .kube/config to work inside distroless ...
# export IMAGE_TAG="${image_tag}"
# envsubst "\$IMAGE_TAG \$PYTHON_VERSION \$OS_VERSION" < ./tests/kubernetes/k8s.yaml | kubectl apply -n=default -f -
# kubectl rollout status deploy/distroless-python-test-"${PYTHON_VERSION}"-"${OS_VERSION}" -n=default --timeout=120s

# sleep 10

# output=$(kubectl logs -l=app=distroless-python-test-"${PYTHON_VERSION}"-"${OS_VERSION}" -n=default)


kind delete cluster --name="${CLUSTER}"
