#!/bin/bash

# Terraformの出力を取得
cd terraform/prod
terraform_output=$(terraform output -json)
cd ../..

# serviceをデプロイ
kubectl apply -f ./k8s/service/api.yaml
kubectl apply -f ./k8s/service/frontend.yaml

# 環境変数の定義を作成
echo "POSTGRES_DB=$(echo $terraform_output | jq -r '.db_name.value')" > api/config/secret/demo.env
echo "POSTGRES_USER=$(echo $terraform_output | jq -r '.db_user_name.value')" >> api/config/secret/demo.env
echo "POSTGRES_PASSWORD=$(echo $terraform_output | jq -r '.db_user_password.value')" >> api/config/secret/demo.env
echo "INSTANCE_CONNECTION_NAME=$(echo $terraform_output | jq -r '.db_connection_name.value')" >> api/config/secret/demo.env
echo "POSTGRES_HOST=127.0.0.1" >> api/config/secret/demo.env
echo "SECRET_KEY_BASE=$(openssl rand -hex 64)" >> api/config/secret/demo.env
echo "CORS_ALLOWED_ORIGINS=http://$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" >> api/config/secret/demo.env

# KubernetesのSecretを作成
kubectl create secret generic api-secret --from-env-file ./api/config/secret/demo.env --dry-run=client -o yaml | kubectl apply -f -

# デモファイルを確認
cat api/config/secret/demo.env
