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
docker build -t memo-app-frontend-prod:latest -f Dockerfile.prod .
docker tag memo-app-frontend-prod asia-northeast1-docker.pkg.dev/matao0214-demo/docker/memo-app-frontend:latest
docker push asia-northeast1-docker.pkg.dev/matao0214-demo/docker/memo-app-frontend:latest
### Apply for GKE
cd k8s/
kubectl apply -f ./deployment/frontend.yaml
kubectl apply -f ./service/frontend.yaml

### Connect gke cluster
gcloud container clusters get-credentials example-autopilot-cluster --region asia-northeast1 --project matao0214-demo

## Api
cd api/

### Create secret
kubectl create secret generic --save-config postgres-secret --from-env-file ./config/secret/prod.env
### Push imaga to Artifact Registry
docker build -t memo-app-api-prod:latest -f Dockerfile.prod .      
docker tag memo-app-api-prod:latest asia-northeast1-docker.pkg.dev/matao0214-demo/docker/memo-app-api:latest
docker push asia-northeast1-docker.pkg.dev/matao0214-demo/docker/memo-app-api:latest
### Apply for GKE
cd k8s/
kubectl apply -f ./deployment/api.yaml
kubectl apply -f ./service/api.yaml

### Migration database
https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine?hl=ja#about_connecting_to

gcloud iam service-accounts create cloudsql-connect \
    --display-name="Cloud SQL Connect Service Account"

gcloud projects add-iam-policy-binding matao0214-demo \
    --member="serviceAccount:cloudsql-connect@matao0214-demo.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin"

kubectl apply -f ./service_account/cloud-sql-proxy.yaml

gcloud iam service-accounts add-iam-policy-binding \
--role="roles/iam.workloadIdentityUser" \
--member="serviceAccount:matao0214-demo.svc.id.goog[default/cloud-sql-proxy]" \
cloudsql-connect@matao0214-demo.iam.gserviceaccount.com

kubectl annotate serviceaccount \
cloud-sql-proxy \
iam.gke.io/gcp-service-account=cloudsql-connect@matao0214-demo.iam.gserviceaccount.com

rails db:create db:migrate RAILS_ENV=production

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

