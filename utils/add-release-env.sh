#!/bin/bash

# Usage:
# 
# add-release-env.sh TENANT_NAME RELEASE_NAME REPO_URL REPO_BRANCH_NAME


TENANT_NAME=$1
RELEASE_NAME=$2
REPO_URL=$3
REPO_BRANCH_NAME=$4
ENV_NAME=$(cat ./ENV_NAME)-$RELEASE_NAME
NAMESPACE_NAME=$ENV_NAME-$TENANT_NAME
source ./utils/update-name.sh

# add to tenants/base
BASE_TENANT_FOLDER=./tenants/base/$TENANT_NAME
BASE_APP_FOLDER=./tenants/base/$TENANT_NAME/$APP_NAME
BASE_RELEASE_FOLDER=./tenants/base/$TENANT_NAME/releases/$RELEASE_NAME
mkdir -p $BASE_RELEASE_FOLDER
flux create tenant $TENANT_NAME --with-namespace=$NAMESPACE_NAME  --export > $BASE_RELEASE_FOLDER/rbac.yaml
flux create source git $TENANT_NAME-$RELEASE_NAME-manifests \
    --namespace=$NAMESPACE_NAME \
    --url=$REPO_URL \
    --branch=$REPO_BRANCH_NAME \
    --export > $BASE_RELEASE_FOLDER/git-manifests.yaml


cd $BASE_RELEASE_FOLDER 
kustomize create --autodetect --namespace $NAMESPACE_NAME
cd -  

cd $BASE_TENANT_FOLDER
kustomize edit add resource releases/$RELEASE_NAME
cd -

for app in `find ./tenants/base/$TENANT_NAME -type d -not -path "./tenants/base/$TENANT_NAME/releases" -maxdepth 1 -mindepth 1`; do \
    APP_NAME=$(basename $app)
    APP_FOLDER=$BASE_TENANT_FOLDER/$APP_NAME
    APP_FOLDER_RELEASE_FOLDERR=$APP_FOLDER/releases/$RELEASE_NAME
    mkdir -p $APP_FOLDER_RELEASE_FOLDERR
    cp ./utils/templates/tenants/app/base/* $APP_FOLDER_RELEASE_FOLDERR/
    update_name $APP_FOLDER_RELEASE_FOLDERR 'APP_NAME' $APP_NAME
    update_name $APP_FOLDER_RELEASE_FOLDERR 'TENANT_NAME' $TENANT_NAME
    update_name $APP_FOLDER_RELEASE_FOLDERR 'ENV_NAME' $ENV_NAME
    update_name $APP_FOLDER_RELEASE_FOLDERR 'GIT_REPOSITORY_NAME' $TENANT_NAME-$RELEASE_NAME-manifests
    cd $APP_FOLDER
    kustomize edit add resource releases/$RELEASE_NAME
    cd -
done


# cp ./utils/templates/tenants/app/base/* $BASE_APP_FOLDER/
# update_name $BASE_APP_FOLDER 'APP_NAME' $APP_NAME
# update_name $BASE_APP_FOLDER 'TENANT_NAME' $TENANT_NAME
# update_name $BASE_APP_FOLDER 'ENV_NAME' $ENV_NAME


# # add to each cluster
# for cluster in `find ./clusters -type d -not -path "./clusters/base" -maxdepth 1 -mindepth 1`; do \
#     CLUSTER_NAME=$(basename $cluster)
#     APP_CLUSTER_FOLDER=./tenants/$CLUSTER_NAME/$TENANT_NAME/$APP_NAME
#     mkdir -p $APP_CLUSTER_FOLDER
#     cp ./utils/templates/tenants/app/cluster/* $APP_CLUSTER_FOLDER/
#     update_name $APP_CLUSTER_FOLDER 'APP_NAME' $APP_NAME
#     update_name $APP_CLUSTER_FOLDER 'TENANT_NAME' $TENANT_NAME
#     update_name $APP_CLUSTER_FOLDER 'CLUSTER_NAME' $CLUSTER_NAME
#     update_name $APP_CLUSTER_FOLDER 'ENV_NAME' $ENV_NAME
    
#     cd ./tenants/$CLUSTER_NAME/$TENANT_NAME 
#     rm -f kustomization.yaml
#     kustomize create --autodetect --recursive --resources ../../base/$TENANT_NAME  
#     cd -  
#     for remote_cluster in `find $cluster -type d -maxdepth 1 -mindepth 1`; do \
#         REMOTE_CLUSTER_NAME=$(basename $remote_cluster)
#         APP_REMOTE_CLUSTER_FOLDER=./tenants/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME/$TENANT_NAME/$APP_NAME
#         mkdir -p $APP_REMOTE_CLUSTER_FOLDER
#         cp ./utils/templates/tenants/app/remote/* $APP_REMOTE_CLUSTER_FOLDER/
#         update_name $APP_REMOTE_CLUSTER_FOLDER 'APP_NAME' $APP_NAME
#         update_name $APP_REMOTE_CLUSTER_FOLDER 'TENANT_NAME' $TENANT_NAME
#         update_name $APP_REMOTE_CLUSTER_FOLDER 'CLUSTER_NAME' $CLUSTER_NAME
#         update_name $APP_REMOTE_CLUSTER_FOLDER 'ENV_NAME' $ENV_NAME
#         update_name $APP_REMOTE_CLUSTER_FOLDER 'REMOTE_CLUSTER_NAME' $REMOTE_CLUSTER_NAME
#         cd ./tenants/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME/$TENANT_NAME
#         rm -f kustomization.yaml
#         kustomize create --autodetect --recursive --resources ../../../../base/$TENANT_NAME  
#         cd -
#     done
# done


