#!/bin/bash

# Usage:
# 
# add-app.sh TENANT_NAME APP_NAME


TENANT_NAME=$1
APP_NAME=$2
ENV_NAME=$(cat ./ENV_NAME)
source ./utils/update-name.sh

# add to tenants/base
BASE_APP_FOLDER=./tenants/base/$TENANT_NAME/$APP_NAME
mkdir -p $BASE_APP_FOLDER 
cp ./utils/templates/tenants/app/base/* $BASE_APP_FOLDER/
update_name $BASE_APP_FOLDER 'APP_NAME' $APP_NAME
update_name $BASE_APP_FOLDER 'TENANT_NAME' $TENANT_NAME
update_name $BASE_APP_FOLDER 'ENV_NAME' $ENV_NAME
update_name $BASE_APP_FOLDER 'GIT_REPOSITORY_NAME' $TENANT_NAME-manifests


# add to each cluster
for cluster in `find ./clusters -type d -not -path "./clusters/base" -maxdepth 1 -mindepth 1`; do \
    CLUSTER_NAME=$(basename $cluster)
    APP_CLUSTER_FOLDER=./tenants/$CLUSTER_NAME/$TENANT_NAME/$APP_NAME
    mkdir -p $APP_CLUSTER_FOLDER
    cp ./utils/templates/tenants/app/cluster/* $APP_CLUSTER_FOLDER/
    update_name $APP_CLUSTER_FOLDER 'APP_NAME' $APP_NAME
    update_name $APP_CLUSTER_FOLDER 'TENANT_NAME' $TENANT_NAME
    update_name $APP_CLUSTER_FOLDER 'CLUSTER_NAME' $CLUSTER_NAME
    update_name $APP_CLUSTER_FOLDER 'ENV_NAME' $ENV_NAME
    update_name $APP_CLUSTER_FOLDER 'GIT_REPOSITORY_NAME' $TENANT_NAME-manifests
    
    cd ./tenants/$CLUSTER_NAME/$TENANT_NAME 
    rm -f kustomization.yaml
    kustomize create --autodetect --recursive --resources ../../base/$TENANT_NAME  
    cd -  
    for remote_cluster in `find $cluster -type d -maxdepth 1 -mindepth 1`; do \
        REMOTE_CLUSTER_NAME=$(basename $remote_cluster)
        APP_REMOTE_CLUSTER_FOLDER=./tenants/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME/$TENANT_NAME/$APP_NAME
        mkdir -p $APP_REMOTE_CLUSTER_FOLDER
        cp ./utils/templates/tenants/app/remote/* $APP_REMOTE_CLUSTER_FOLDER/
        update_name $APP_REMOTE_CLUSTER_FOLDER 'APP_NAME' $APP_NAME
        update_name $APP_REMOTE_CLUSTER_FOLDER 'TENANT_NAME' $TENANT_NAME
        update_name $APP_REMOTE_CLUSTER_FOLDER 'CLUSTER_NAME' $CLUSTER_NAME
        update_name $APP_REMOTE_CLUSTER_FOLDER 'ENV_NAME' $ENV_NAME
        update_name $APP_REMOTE_CLUSTER_FOLDER 'REMOTE_CLUSTER_NAME' $REMOTE_CLUSTER_NAME
        update_name $APP_REMOTE_CLUSTER_FOLDER 'GIT_REPOSITORY_NAME' $TENANT_NAME-manifests
        cd ./tenants/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME/$TENANT_NAME
        rm -f kustomization.yaml
        kustomize create --autodetect --recursive --resources ../../../../base/$TENANT_NAME  
        cd -
    done
done


