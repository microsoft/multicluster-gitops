 #!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Usage:
# 
# remove-cluster.sh CLUSTER_NAME

CLUSTER_NAME=$1

rm -r ./clusters/$CLUSTER_NAME
rm -r ./infra/$CLUSTER_NAME





