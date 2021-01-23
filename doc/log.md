### Bootstrap a new cluster 

export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
export GITHUB_REPO=<repository-name>

flux check --pre

flux bootstrap github \
    --owner=kaizentm \
    --repository=${GITHUB_REPO} \
    --branch=dev \
    --path=clusters/k3d-america