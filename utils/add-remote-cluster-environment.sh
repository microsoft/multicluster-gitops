 #!/bin/bash

# Usage:
# 
# add-remote-cluster-environment.sh CLUSTER_NAME REMOTE_CLUSTER_NAME

CLUSTER_NAME=$1
REMOTE_CLUSTER_NAME=$2
ENV_NAME=$(cat ./ENV_NAME)
source ./utils/update-name.sh
source ./utils/add-tenant-remote-cluster.sh

# add to clusters folder
mkdir -p  ./clusters/$CLUSTER_NAME
mkdir -p  ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME
cp ./utils/templates/clusters/remote/*.yaml ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME
update-name.sh ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME 'CLUSTER_NAME' $CLUSTER_NAME
update-name.sh ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME 'ENV_NAME' $ENV_NAME

# add to infra folder
mkdir -p  ./infra/$CLUSTER_NAME
mkdir -p  ./infra/$CLUSTER_NAME/clusters
mkdir -p  ./infra/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME
cp ./utils/templates/infra/remote/*.yaml ./infra/$CLUSTER_NAME/

# add to tenants folder
mkdir -p  ./tenants/$CLUSTER_NAME
mkdir -p  ./tenants/$CLUSTER_NAME/clusters
mkdir -p  ./tenants/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME

for tenant in `find ./tenants/base -type d -maxdepth 1 -mindepth 1`; do \
    TENANT_NAME=$(basename $tenant)
    add-tenant-remote-cluster $CLUSTER_NAME $REMOTE_CLUSTER_NAME $TENANT_NAME
done
cd ./tenants/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME 
kustomize create --autodetect --recursive
cd -

update-name.sh ./tenants/$CLUSTER_NAME 'CLUSTER_NAME' $CLUSTER_NAME
update-name.sh ./tenants/$CLUSTER_NAME 'ENV_NAME' $ENV_NAME
update-name.sh ./tenants/$CLUSTER_NAME 'REMOTE_CLUSTER_NAME' $REMOTE_CLUSTER_NAME

kustomize build ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME | kubectl apply -f-


