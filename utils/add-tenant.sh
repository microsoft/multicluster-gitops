 #!/bin/bash

# Usage:
# 
# add-tenant.sh TENANT_NAME REPO_URL REPO_BRANCH_NAME

TENANT_NAME=$1
REPO_URL=$2
REPO_BRANCH_NAME=$3
ENV_NAME=$(cat ./ENV_NAME)
NAMESPACE_NAME=$ENV_NAME-$TENANT_NAME

# add to tenants/base
BASE_TENANT_FOLDER=./tenants/base/$TENANT_NAME
rm -r -f $BASE_TENANT_FOLDER
mkdir -p $BASE_TENANT_FOLDER
flux create tenant $TENANT_NAME --with-namespace=$NAMESPACE_NAME  --export > $BASE_TENANT_FOLDER/rbac.yaml
flux create source git $TENANT_NAME-manifests \
    --namespace=$NAMESPACE_NAME \
    --url=$REPO_URL \
    --branch=$REPO_BRANCH_NAME \
    --export > $BASE_TENANT_FOLDER/git-manifests.yaml


cd $BASE_TENANT_FOLDER 
kustomize create --autodetect --namespace $NAMESPACE_NAME
cd -  

# add to each cluster
for cluster in `find ./clusters -type d -not -path "./clusters/base" -maxdepth 1 -mindepth 1`; do \
    CLUSTER_NAME=$(basename $cluster)
    CLUSTER_FOLDER=./tenants/$CLUSTER_NAME
    mkdir -p $CLUSTER_FOLDER
    ./utils/add-tenant-cluster.sh $CLUSTER_NAME $TENANT_NAME
    cd $CLUSTER_FOLDER 
    rm -f kustomization.yaml
    kustomize create --autodetect --recursive
    cd -  
done



