#!/bin/bash

# Terraformの出力を取得
cd terraform/prod
terraform_output=$(terraform output -json)
cd ../..

# 環境変数の定義を作成
echo "POSTGRES_DB=$(echo $terraform_output | jq -r '.db_name.value')" > api/config/secret/demo.env
echo "POSTGRES_USER=$(echo $terraform_output | jq -r '.db_user.value')" >> api/config/secret/demo.env
echo "POSTGRES_PASSWORD=$(echo $terraform_output | jq -r '.db_user_password.value')" >> api/config/secret/demo.env
echo "DB_CONNECTION_NAME=$(echo $terraform_output | jq -r '.db_connection_name.value')" >> api/config/secret/demo.env
echo "POSTGRES_HOST=127.0.0.1" >> api/config/secret/demo.env
echo "SECRET_KEY_BASE=$(openssl rand -hex 64)" >> api/config/secret/demo.env

# KubernetesのSecretを作成
kubectl create secret generic api-secret --from-env-file ./api/config/secret/demo.env --dry-run=client -o yaml | kubectl apply -f -

# デモファイルを確認
cat api/config/secret/demo.env
