# Start local
cd docker/
docker compose up -d

Access: http://localhost:3001/

# Auto deploy for GKE
## Initialize
### Create gihub access token
https://github.com/settings/tokens
Create Token by "Token(classic)", not beta.
Paste the access token into terraform/modules/cloud_build/my-github-token.txt

### Check github install ID
https://github.com/apps/google-cloud-build/installations/select_target
Paste the number at the end of the linked URL into terraform/modules/cloud_build/my-github-app-installation-id.txt

### Check repo URL
Paste the repo URL into terraform/modules/cloud_build/my-github-repo-url.txt
ex) https://github.com/matao0214/memo-app.git

## Setup and deploy for GKE
cd ~
sh ./script/setup.sh

# Application Reference
https://zenn.dev/jinku/articles/92b76bf09d5351

# Deploy from local
Create the infrastructure in advance, including authentication with gke.

gcloud container clusters get-credentials example-autopilot-cluster --region asia-northeast1 --project matao0214-demo

## Frontend
### Push imaga to Artifact Registry
cd frontend/
docker build -t memo-app-frontend-prod:latest -f Dockerfile.prod .
docker tag memo-app-frontend-prod asia-northeast1-docker.pkg.dev/matao0214-demo/docker/memo-app-frontend:latest
docker push asia-northeast1-docker.pkg.dev/matao0214-demo/docker/memo-app-frontend:latest
### Apply for GKE
cd k8s/
kubectl apply -f ./deployment/frontend.yaml
kubectl apply -f ./service/frontend.yaml

## Api
### Push imaga to Artifact Registry
cd api/
docker build -t memo-app-api-prod:latest -f Dockerfile.prod .      
docker tag memo-app-api-prod:latest asia-northeast1-docker.pkg.dev/matao0214-demo/docker/memo-app-api:latest
docker push asia-northeast1-docker.pkg.dev/matao0214-demo/docker/memo-app-api:latest
### Apply for GKE
cd k8s/
kubectl apply -f ./deployment/api.yaml
kubectl apply -f ./service/api.yaml

### Migration database
kubectl get pod
kubectl exec -it ${pod_name} -- /bin/bash
rails db:create db:migrate RAILS_ENV=production

# Terraform
## Vulnerability Check
cd terraform 

brew install trivy
trivy config ./main.tf 

brew install checkov
checkov --file ./main.tf 

## Setting terraform precommit
https://dev.classmethod.jp/articles/pre-commit-terraform-introduction/
brew install pre-commit
pre-commit install

# Clean up
cd ~
sh ./script/cleanup.sh
