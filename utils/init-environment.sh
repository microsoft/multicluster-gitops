#!/bin/bash

# Usage:
# 
# init-environment.sh ENV_NAME REPO_URL


ENV_NAME=$1
REPO_URL=$2

echo $ENV_NAME > ENV_NAME

rm -r -f ./clusters/*
mkdir ./clusters/base
cp ./utils/templates/clusters/base/* ./clusters/base/
./utils/update-name.sh ./clusters/base/ 'REPO_URL' $REPO_URL
./utils/update-name.sh ./clusters/base/ 'ENV_NAME' $ENV_NAME

rm -r -f ./infra/*
mkdir ./infra/base

rm -r -f ./tenants/*
mkdir ./tenants/base