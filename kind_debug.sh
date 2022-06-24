#!/usr/bin/env bash
set -ouE pipefail

curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

CLUSTER=distroless-test-$(( RANDOM%100000 ))

echo "DEBUG: create cluster"
kind create cluster --name="${CLUSTER}" --config=kind.yaml --wait=60s

echo "DEBUG: list clusters"
kind get clusters

echo "DEBUG: cluster context"
cat /root/.kube/config

docker ps

# will fail, not auth'd
echo "DBEUG: 127.0.0.1"
curl -v https://127.0.0.1:6443/api --insecure

echo "DEBUG: localhost"
curl -v https://localhost:6443/api --insecure

echo "DEBUG: docker"
curl -v https://docker:6443/api --insecure


echo "DEBUG: get cluster info (kind*)"
kubectl cluster-info --context kind-${CLUSTER}

echo "DEBUG: get namespaces (kind*)"
kubectl get ns --context kind-${CLUSTER}

kubectl config set-cluster kind-${CLUSTER} --server=https://docker:6443

echo "DEBUG: get cluster info (kind*)"
kubectl cluster-info --context kind-${CLUSTER}

# # believe it or not this seems easier than getting .kube/config to work inside distroless ...
# export IMAGE_TAG="${image_tag}"
# envsubst "\$IMAGE_TAG \$PYTHON_VERSION \$OS_VERSION" < ./tests/kubernetes/k8s.yaml | kubectl apply -n=default -f -
# kubectl rollout status deploy/distroless-python-test-"${PYTHON_VERSION}"-"${OS_VERSION}" -n=default --timeout=120s

# sleep 10

# output=$(kubectl logs -l=app=distroless-python-test-"${PYTHON_VERSION}"-"${OS_VERSION}" -n=default)


kind delete cluster --name="${CLUSTER}"
