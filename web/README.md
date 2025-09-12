# Go Web API (web)

このディレクトリはGo（Gin）で実装されたAPIサーバです。

## 主な機能
- TodoのCRUD（PostgreSQL永続化）
- CORS対応
- Docker/Docker Compose対応

## 開発・起動方法

### ローカルで直接起動
1. 依存パッケージのインストール
   ```sh
   go mod tidy
   ```
2. ビルド
   ```sh
   go build -o app .
   ```
3. PostgreSQLを用意し、環境変数を設定して起動
   ```sh
   export POSTGRES_HOST=localhost
   export POSTGRES_USER=user
   export POSTGRES_PASSWORD=postgres
   export POSTGRES_DB=myapi_development
   ./app
   ```

### Docker Composeで起動
1. プロジェクトルートで
   ```sh
   docker compose up --build
   ```
2. APIエンドポイント: `http://localhost:8080/todos`

## テスト
```sh
go test -v
```

## ディレクトリ構成
- `main.go` ... エントリポイント
- `db.go` ... DB接続・初期化
- `cors.go` ... CORSミドルウェア
- `todo_test.go` ... 単体テスト

## 注意
- DBスキーマは自動作成されます
- 本番運用時はCORSやDB接続設定を適切に変更してください
