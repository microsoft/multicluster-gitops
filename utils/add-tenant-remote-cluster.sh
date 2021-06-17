#!/bin/bash

# Usage:
# 
# add-tenant-remote-cluster.sh CLUSTER_NAME REMOTE_CLUSTER_NAME TENANT_NAME

source ./utils/update-name.sh

add-tenant-remote-cluster() {
    CLUSTER_NAME=$1
    REMOTE_CLUSTER_NAME=$2
    TENANT_NAME=$3

    TENANT_FOLDER=./tenants/$CLUSTER_NAME/clusters/$REMOTE_CLUSTER_NAME/$TENANT_NAME
    rm -r -f $TENANT_FOLDER 
    mkdir -p $TENANT_FOLDER 
    for app in `find ./tenants/base/$TENANT_NAME -type d -not -path "./tenants/base/$TENANT_NAME/releases" -maxdepth 1 -mindepth 1`; do \
        APP_NAME=$(basename $app)
        APP_FOLDER=$TENANT_FOLDER/$APP_NAME
        mkdir -p $APP_FOLDER
        cp ./utils/templates/tenants/app/remote/* $APP_FOLDER/
        update_name $APP_FOLDER 'APP_NAME' $APP_NAME
    done
    cd $TENANT_FOLDER 
    kustomize create --autodetect --recursive --resources ../../../../base/$TENANT_NAME  
    cd -  
    update_name $TENANT_FOLDER 'TENANT_NAME' $TENANT_NAME

}

