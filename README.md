# Start local
cd docker/
docker compose up -d

# Reference
フロントエンド、バックエンドは以下を参考に作成
https://zenn.dev/jinku/articles/92b76bf09d5351

# Deploy
## Frontend
cd frontend/
### Push imaga to Artifact Registry
docker build -t memo-app-frontend-p:latest -f Dockerfile.prod .      
docker tag memo-app-frontend-prod asia-northeast1-docker.pkg.dev/matao0214-demo/docker/memo-app-frontend:latest
docker push asia-northeast1-docker.pkg.dev/matao0214-demo/docker/memo-app-frontend:latest
### Apply for GKE
cd k8s/
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

## Terraform
terraform fmt
terraform plan
terraform apply

# Vulnerability Check
cd terraform 

brew install trivy
trivy config ./main.tf 

brew install checkov
checkov --file ./main.tf 

# Setting terraform precommit
https://dev.classmethod.jp/articles/pre-commit-terraform-introduction/
brew install pre-commit
pre-commit install

