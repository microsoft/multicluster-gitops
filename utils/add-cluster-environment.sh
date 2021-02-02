 #!/bin/bash

# Usage:
# 
# add-cluster-environment.sh CLUSTER_NAME

CLUSTER_NAME=$1
ENV_NAME=$(cat ./ENV_NAME)

# add to clusters folder
mkdir -p  ./clusters/$CLUSTER_NAME
cp ./utils/templates/clusters/cluster/*.yaml ./clusters/$CLUSTER_NAME/
./utils/update-name.sh ./clusters/$CLUSTER_NAME 'CLUSTER_NAME' $CLUSTER_NAME
./utils/update-name.sh ./clusters/$CLUSTER_NAME 'ENV_NAME' $ENV_NAME

# add to infra folder
mkdir -p  ./infra/$CLUSTER_NAME
cp ./utils/templates/infra/*.yaml ./infra/$CLUSTER_NAME/

# add to tenants folder
mkdir -p  ./tenants/$CLUSTER_NAME

for tenant in `find ./tenants/base -type d -maxdepth 1 -mindepth 1`; do \
    TENANT_NAME=$(basename $tenant)
    ./utils/add-tenant-cluster.sh $CLUSTER_NAME $TENANT_NAME
done
cd ./tenants/$CLUSTER_NAME 
kustomize create --autodetect --recursive
cd -

./utils/update-name.sh ./tenants/$CLUSTER_NAME 'CLUSTER_NAME' $CLUSTER_NAME
./utils/update-name.sh ./tenants/$CLUSTER_NAME 'ENV_NAME' $ENV_NAME

kustomize build ./clusters/$CLUSTER_NAME | kubectl apply -f-



