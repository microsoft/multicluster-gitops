ACR_NAME=gitopsflowacr.azurecr.io
ACR_UNAME=$(az acr credential show -n $ACR_NAME --query="username" -o tsv)
ACR_PASSWD=$(az acr credential show -n $ACR_NAME --query="passwords[0].value" -o tsv)


kubectl create secret docker-registry acr-secret \
  --docker-server=$ACR_NAME \
  --docker-username=$ACR_UNAME \
  --docker-password=$ACR_PASSWD \
  --docker-email=ignorethis@email.com \
  --namespace dev-kaizentm


  kubectl patch crd helmreleases.helm.toolkit.fluxcd.io --type=merge --patch '{"metadata":{"finalizers":[]}}'