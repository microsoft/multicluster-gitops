 #!/bin/bash

# Usage:
# 
# add-remote-cluster-environment.sh CLUSTER_NAME REMOTE_CLUSTER_NAME KUBE_CONFIG_FILE

CLUSTER_NAME=$1
REMOTE_CLUSTER_NAME=$2
KUBE_CONFIG_FILE=$3
ENV_NAME=$(cat ./ENV_NAME)
source ./utils/update-name.sh
source ./utils/add-tenant-remote-cluster.sh

create_remote_secret() {
    SECRET_PREFIX=$1
    NAMESPACE=$2    
    kubectl create namespace $NAMESPACE --dry-run='client' -o yaml | kubectl apply -f-
    kubectl -n $NAMESPACE create secret generic $SECRET_PREFIX-kubeconfig --from-file=value=$KUBE_CONFIG_FILE --dry-run='client' -o yaml | kubectl apply -f-
}

# add to clusters folder
mkdir -p  ./clusters/$CLUSTER_NAME
mkdir -p  ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME
cp ./utils/templates/clusters/remote/*.yaml ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME
update_name ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME 'CLUSTER_NAME' $CLUSTER_NAME
update_name ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME 'ENV_NAME' $ENV_NAME
update_name ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME 'REMOTE_CLUSTER_NAME' $REMOTE_CLUSTER_NAME
create_remote_secret $REMOTE_CLUSTER_NAME $ENV_NAME-flux-system

# add to infra folder
mkdir -p  ./infra/$CLUSTER_NAME
mkdir -p  ./infra/$CLUSTER_NAME/clusters
mkdir -p  ./infra/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME
cp ./utils/templates/infra/remote/*.yaml ./infra/$CLUSTER_NAME/

# add to tenants folder
rm -r -f ./tenants/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME
mkdir -p  ./tenants/$CLUSTER_NAME
mkdir -p  ./tenants/$CLUSTER_NAME/clusters
mkdir -p  ./tenants/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME

for tenant in `find ./tenants/base -type d -maxdepth 1 -mindepth 1`; do \
    TENANT_NAME=$(basename $tenant)
    add-tenant-remote-cluster $CLUSTER_NAME $REMOTE_CLUSTER_NAME $TENANT_NAME
    create_remote_secret $REMOTE_CLUSTER_NAME $ENV_NAME-$TENANT_NAME
done
cd ./tenants/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME 
kustomize create --autodetect --recursive
cd -

update_name ./tenants/$CLUSTER_NAME 'CLUSTER_NAME' $CLUSTER_NAME
update_name ./tenants/$CLUSTER_NAME 'ENV_NAME' $ENV_NAME
update_name ./tenants/$CLUSTER_NAME 'REMOTE_CLUSTER_NAME' $REMOTE_CLUSTER_NAME                                     

# kustomize build ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME | kubectl apply -f-
kustomize build ./clusters/$CLUSTER_NAME/$REMOTE_CLUSTER_NAME


