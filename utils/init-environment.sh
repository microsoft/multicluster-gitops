#!/bin/bash

# Usage:
# 
# init-environment.sh ENV_NAME

source ./utils/update-name.sh

ENV_NAME=$1

echo $ENV_NAME > ENV_NAME

rm -r -f ./clusters/*
mkdir ./clusters/base
cp ./utils/templates/clusters/base/* ./clusters/base/
update_name ./clusters/base/ 'ENV_NAME' $ENV_NAME

rm -r -f ./infra/*
mkdir ./infra/base

rm -r -f ./tenants/*
mkdir ./tenants/base