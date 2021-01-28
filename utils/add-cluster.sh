 #!/bin/bash

# Usage:
# 
# export GITHUB_TOKEN=<your-token>
# export GITHUB_USER=<your-username>
# export GITHUB_REPO=<repository-name>
#
# add-cluster.sh CLUSTER_NAME

CLUSTER_NAME=$1

mkdir -p  ./clusters/$CLUSTER_NAME
cp ./utils/templates/clusters/infra.yaml ./clusters/$CLUSTER_NAME/infra.yaml
sed -i 's/{CLUSTER_NAME}/'$CLUSTER_NAME'/g' ./clusters/$CLUSTER_NAME/infra.yaml

mkdir -p  ./infra/$CLUSTER_NAME
cp ./utils/templates/infra/kustomization.yaml ./infra/$CLUSTER_NAME/kustomization.yaml


flux bootstrap github \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --branch=main \
    --path=clusters/base

kubectl apply -f clusters/$CLUSTER_NAME/infra.yaml




