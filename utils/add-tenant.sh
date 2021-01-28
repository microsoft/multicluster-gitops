 #!/bin/bash

# Usage:
# 
# add-tenant.sh TENANT_NAME REPO_URL REPO_BRANCH_NAME

TENANT_NAME=$1
REPO_URL=$2
REPO_BRANCH_NAME=$2
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

# cp ./utils/templates/tenants/* $BASE_TENANT_FOLDER/
# ./utils/update-name.sh $BASE_TENANT_FOLDER 'ENV_NAME' $ENV_NAME
# ./utils/update-name.sh $BASE_TENANT_FOLDER 'TENANT_NAME' $TENANT_NAME

# mkdir -p  ./clusters/$CLUSTER_NAME
# cp ./utils/templates/clusters/* ./clusters/$CLUSTER_NAME/
# ./utils/update-name.sh ./clusters/$CLUSTER_NAME 'CLUSTER_NAME' $CLUSTER_NAME
# ./utils/update-name.sh ./clusters/$CLUSTER_NAME 'ENV_NAME' $ENV_NAME

# # add to infra folder
# mkdir -p  ./infra/$CLUSTER_NAME
# cp ./utils/templates/infra/* ./infra/$CLUSTER_NAME/

# # add to tenants folder
# mkdir -p  ./tenants/$CLUSTER_NAME

# for tenant in `find ./tenants/base -type d -maxdepth 1 -mindepth 1`; do \
#     TENANT_NAME=$(basename $tenant)
#     TENANT_FOLDER=./tenants/$CLUSTER_NAME/$TENANT_NAME
#     mkdir -p $TENANT_FOLDER 
#     for app in `find $tenant -type d -maxdepth 1 -mindepth 1`; do \
#       APP_NAME=$(basename $app)
#       APP_FOLDER=$TENANT_FOLDER/$APP_NAME
#       mkdir -p $APP_FOLDER
#       cp ./utils/templates/tenants/app/* $APP_FOLDER/
#       ./utils/update-name.sh $APP_FOLDER 'APP_NAME' $APP_NAME
#     done
#     cd $TENANT_FOLDER 
#     kustomize create --autodetect --recursive --resources ../../base/$TENANT_NAME  
#     cd $ROOT_FOLDER  
#     ./utils/update-name.sh ./tenants/$CLUSTER_NAME/$TENANT_NAME 'TENANT_NAME' $TENANT_NAME
# done
# cd ./tenants/$CLUSTER_NAME 
# kustomize create --autodetect --recursive
# cd $ROOT_FOLDER  

# ./utils/update-name.sh ./tenants/$CLUSTER_NAME 'CLUSTER_NAME' $CLUSTER_NAME
# ./utils/update-name.sh ./tenants/$CLUSTER_NAME 'ENV_NAME' $ENV_NAME

# kustomize build ./clusters/$CLUSTER_NAME | kubectl apply -f-



