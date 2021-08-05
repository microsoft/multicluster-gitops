# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Install cluster ctl 
# https://cluster-api.sigs.k8s.io/user/quick-start.html#install-clusterctl

# Download and install clusterawsadm 
# https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases

export AWS_REGION=
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export EXP_EKS=true
export EXP_EKS_IAM=true
export EXP_EKS_ADD_ROLES=true

clusterawsadm bootstrap iam create-cloudformation-stack --config bootstrap-config.yaml

export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm bootstrap credentials encode-as-profile)

clusterctl init --infrastructure aws --control-plane aws-eks --bootstrap aws-eks

kubectl apply -f role-binding.yaml
