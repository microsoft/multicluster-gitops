#!/bin/bash

# Usage:
# 
# add-tenant-cluster.sh CLUSTER_NAME TENANT_NAME

CLUSTER_NAME=$1
TENANT_NAME=$2

TENANT_FOLDER=./tenants/$CLUSTER_NAME/$TENANT_NAME
rm -r -f $TENANT_FOLDER 
mkdir -p $TENANT_FOLDER 
for app in `find ./tenants/base/$TENANT_NAME -type d -maxdepth 1 -mindepth 1`; do \
    APP_NAME=$(basename $app)
    APP_FOLDER=$TENANT_FOLDER/$APP_NAME
    mkdir -p $APP_FOLDER
    cp ./utils/templates/tenants/app/* $APP_FOLDER/
    ./utils/update-name.sh $APP_FOLDER 'APP_NAME' $APP_NAME
done
cd $TENANT_FOLDER 
kustomize create --autodetect --recursive --resources ../../base/$TENANT_NAME  
cd -  
./utils/update-name.sh ./tenants/$CLUSTER_NAME/$TENANT_NAME 'TENANT_NAME' $TENANT_NAME

