#!/bin/bash

# Source : https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries

# Note : Kind software is not accurate for config file localisations, but is still good for objets applied on the cluster

# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install kubectl 
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod u+x kubectl
sudp mv kubectl /usr/local/bin/

echo done
echo type this command to create your cluster
echo "kind create cluster"

