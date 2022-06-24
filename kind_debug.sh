#!/usr/bin/env bash
set -ouE pipefail

curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

CLUSTER=distroless-test-$(( RANDOM%100000 ))

echo "DEBUG: create cluster"
kind create cluster --name="${CLUSTER}" --config=kind.yaml --wait=60s

# echo "DEBUG: list clusters"
# kind get clusters

# echo "DEBUG: cluster context"
# cat /root/.kube/config


# docker ps

kind get kubeconfig --name="${CLUSTER}" | sed -e 's/0.0.0.0/docker/g' > /root/.kube/config

# cat /etc/hosts
# apt-get install -y dnsutils
# echo "$(dig +short docker) kubernetes" >> /etc/hosts


# echo "DEBUG: docker"
# curl -v https://docker:6443/api --insecure

# echo "DEBUG: kubernetes"
# curl -v https://kubernetes:6443/api --insecure


kubectl config set-cluster kind-${CLUSTER} --server=https://docker:6443 --insecure-skip-tls-verify=true

echo "DEBUG: get cluster info (docker)"
kubectl cluster-info --context kind-${CLUSTER}
kubectl get ns --context kind-${CLUSTER}

# kubectl config set-cluster kind-${CLUSTER} --server=https://kubernetes:6443 --insecure-skip-tls-verify=true

# echo "DEBUG: get cluster info (kubernetes)"
# kubectl cluster-info --context kind-${CLUSTER}
# kubectl get ns --context kind-${CLUSTER}


# # believe it or not this seems easier than getting .kube/config to work inside distroless ...
# export IMAGE_TAG="${image_tag}"
# envsubst "\$IMAGE_TAG \$PYTHON_VERSION \$OS_VERSION" < ./tests/kubernetes/k8s.yaml | kubectl apply -n=default -f -
# kubectl rollout status deploy/distroless-python-test-"${PYTHON_VERSION}"-"${OS_VERSION}" -n=default --timeout=120s

# sleep 10

# output=$(kubectl logs -l=app=distroless-python-test-"${PYTHON_VERSION}"-"${OS_VERSION}" -n=default)


kind delete cluster --name="${CLUSTER}"
