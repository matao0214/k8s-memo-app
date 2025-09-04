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

# ArgoCDのデプロイ
echo "---------- Start ArgoCD deploy ----------"
helmfile apply -f k8s/helmfile.yaml
echo "---------- Start ArgoCD application deploy ----------"
kubectl apply -f k8s/argocd/application.yaml

# Run Cloud Build
echo "---------- Start Cloudbuild memo-app-api and memo-app-frontend----------"
API_BUILD_ID=$(gcloud builds triggers run memo-app-api --region=asia-east1 --branch=main --format='value(id)')
FRONTEND_BUILD_ID=$(gcloud builds triggers run memo-app-frontend --region=asia-east1 --branch=main --format='value(id)')

# 直前のmemo-app-apiとmemo-app-frontendのCloudbuild のステータスチェック。10秒ごとに確認して、成功したら次へ進む
while true; do
  API_STATUS=$(gcloud builds describe $API_BUILD_ID --format='value(status)')
  FRONTEND_STATUS=$(gcloud builds describe $FRONTEND_BUILD_ID --format='value(status)')
  if [[ "$API_STATUS" == "SUCCESS" && "$FRONTEND_STATUS" == "SUCCESS" ]]; then
    echo "---------- Both Cloudbuilds succeeded ----------"
    break
  elif [[ "$API_STATUS" == "FAILURE" || "$FRONTEND_STATUS" == "FAILURE" ]]; then
    echo "---------- One of the Cloudbuilds failed ----------"
    exit 1
  fi
  echo "---------- Cloudbuilds are still running... ----------"
  sleep 10
done

# アプリケーションとArgoCDのURLを表示
echo "---------- Application URL: http://$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}') ----------"
echo "---------- Argocd URL: http://$(kubectl get service argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}') ----------"
# Argocd ログイン情報
echo "---------- Argocd admin user: admin ----------"
echo "---------- Argocd admin password: $(kubectl get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode) ----------"
