 #!/bin/bash

# Usage:
# 
# remove-cluster-from-environment.sh CLUSTER_NAME

CLUSTER_NAME=$1
rm -r ./clusters/$CLUSTER_NAME
rm -r ./infra/$CLUSTER_NAME
rm -r ./tenants/$CLUSTER_NAME



