#!/bin/bash

set -e  # Stop on error
set -x  # Display executed commands

# terraform applyでリソース作成
cd terraform/prod
echo "---------- Start terraform apply ----------"
terraform init
terraform apply -auto-approve
cd ../..

# create_secret.shでSecret作成
echo "---------- Reference create_secret.sh ----------"
chmod +x ./script/create_secret.sh
./script/create_secret.sh

# gkeのservice account作成してGCPのサービスアカウントと紐付ける
echo "---------- Create cloud-sql-proxy service account on GKE ----------"
kubectl apply -f k8s/service_account/cloud-sql-proxy.yaml
kubectl annotate serviceaccount \
cloud-sql-proxy \
iam.gke.io/gcp-service-account=cloudsql-connect@matao0214-demo.iam.gserviceaccount.com

# アプリケーションのデプロイ
echo "---------- Start kubectl apply deployment ----------"
gcloud builds triggers run memo-app-api --region=asia-east1 --branch=main
gcloud builds triggers run memo-app-frontend --region=asia-east1 --branch=main
echo "---------- Check build status!!! ----------"
