 #!/bin/bash

# Usage:
# 
# add-app.sh TENANT_NAME APP_NAME APP_FOLDER_NAME


TENANT_NAME=$1
APP_NAME=$2
APP_FOLDER_NAME=$3
ENV_NAME=$(cat ./ENV_NAME)


BASE_APP_FOLDER=./tenants/base/$TENANT_NAME/$APP_NAME
mkdir -p $BASE_APP_FOLDER 
cp ./utils/templates/tenants/app/base/* $BASE_APP_FOLDER/
./utils/update-name.sh $BASE_APP_FOLDER 'APP_NAME' $APP_NAME
./utils/update-name.sh $BASE_APP_FOLDER 'TENANT_NAME' $TENANT_NAME
./utils/update-name.sh $BASE_APP_FOLDER 'ENV_NAME' $ENV_NAME
./utils/update-name.sh $BASE_APP_FOLDER 'APP_FOLDER_NAME' $APP_FOLDER_NAME


# add to each cluster
for cluster in `find ./clusters -type d -not -path "./clusters/base" -maxdepth 1 -mindepth 1`; do \
    CLUSTER_NAME=$(basename $cluster)
    APP_CLUSTER_FOLDER=./tenants/$CLUSTER_NAME/$TENANT_NAME/$APP_NAME
    mkdir -p $APP_CLUSTER_FOLDER
    cp ./utils/templates/tenants/app/cluster/* $APP_CLUSTER_FOLDER/
    ./utils/update-name.sh $APP_CLUSTER_FOLDER 'APP_NAME' $APP_NAME
    ./utils/update-name.sh $APP_CLUSTER_FOLDER 'TENANT_NAME' $TENANT_NAME
    ./utils/update-name.sh $APP_CLUSTER_FOLDER 'CLUSTER_NAME' $CLUSTER_NAME
    ./utils/update-name.sh $APP_CLUSTER_FOLDER 'ENV_NAME' $ENV_NAME
    
    cd ./tenants/$CLUSTER_NAME/$TENANT_NAME 
    rm -f kustomization.yaml
    kustomize create --autodetect --recursive --resources ../../base/$TENANT_NAME  
    cd -  
done


