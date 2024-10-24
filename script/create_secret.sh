#!/bin/bash

echo "---------- Start create secret shell script ----------"

# Terraformの出力を取得
echo "---------- Get terraform output ----------"
cd terraform/prod
terraform_output=$(terraform output -json)
cd ../..

# GKEの認証情報を取得
echo "---------- Get gcloud credentials ----------"
gcloud container clusters get-credentials example-autopilot-cluster --region asia-northeast1 --project matao0214-demo

# serviceをデプロイ
echo "---------- Start kubectl apply services ----------"
kubectl apply -f ./k8s/service/api.yaml
kubectl apply -f ./k8s/service/frontend.yaml

# frontendの外部IPが設定されるまで待つ
echo "---------- Check setting frontend external IP ----------"
echo "---------- Please wait about 3 minutes. ----------"
while [ -z "$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" ]; do
  sleep 10
  echo "---------- 10 seconds... ----------"
done
echo "---------- Finish setting frontend external IP ----------"

# 環境変数の定義を作成
echo "---------- Create prod env file ----------"
echo "POSTGRES_DB=$(echo $terraform_output | jq -r '.db_name.value')" > api/config/secret/prod.env
echo "POSTGRES_USER=$(echo $terraform_output | jq -r '.db_user_name.value')" >> api/config/secret/prod.env
echo "POSTGRES_PASSWORD=$(echo $terraform_output | jq -r '.db_user_password.value')" >> api/config/secret/prod.env
echo "INSTANCE_CONNECTION_NAME=$(echo $terraform_output | jq -r '.db_connection_name.value')" >> api/config/secret/prod.env
echo "POSTGRES_HOST=127.0.0.1" >> api/config/secret/prod.env
echo "SECRET_KEY_BASE=$(openssl rand -hex 64)" >> api/config/secret/prod.env
echo "CORS_ALLOWED_ORIGINS=http://$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" >> api/config/secret/prod.env

# KubernetesのSecretを作成
echo "---------- Create kube secret ----------"
kubectl create secret generic api-secret --from-env-file ./api/config/secret/prod.env --dry-run=client -o yaml | kubectl apply -f -

# デモファイルを確認
echo "---------- Check prod file ----------"
echo "---------- If empty item, rerun this scrpt. ----------"
cat api/config/secret/prod.env

echo "---------- Finish create secret shell script ----------"
echo "---------- Application URL: http://$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}') ----------"
