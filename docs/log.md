### Bootstrap a new cluster 

export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
export GITHUB_REPO=<repository-name>

flux check --pre

flux bootstrap github \
    --owner=kaizentm \
    --repository=${GITHUB_REPO} \
    --branch=main \
    --path=clusters/base

 k apply -f clusters/k3d-america/infra.yaml

<!-- For each env -->



### Bootstrap a new tenant

<!-- For each env -->
    flux create tenant kaizentm --with-namespace=dev-kaizentm  --export > tenants/base/kaizentm/rbac.yaml

    flux create source git kaizentm-manifests \
        --namespace=dev-kaizentm \
        --url=https://github.com/kaizentm/gitops-manifests \
        --branch=multi-dev \
        --export > tenants/base/kaizentm/sync.yaml

    <!-- For each app -->
        flux create kustomization azure-vote \
            --namespace=dev-kaizentm \
            --service-account=kaizentm \
            --source=kaizentm-manifests \
            --path="azure-vote" \
            --export > tenants/base/kaizentm/azure-vote/sync.yaml

        cd ./tenants/base/kaizentm/azure-vote && kustomize create --autodetect
    
    cd ./tenants/base/kaizentm/ && kustomize create --autodetect

    <!-- For each cluster -->