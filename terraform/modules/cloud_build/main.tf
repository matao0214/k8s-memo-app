locals {
  repo_components = [
    "frontend",
  ]
}

resource "google_cloudbuild_trigger" "memo-app" {
  for_each = toset(local.repo_components)

  # memo-app-${変数}の形式でトリガー名を設定
  name           = "memo-app-${each.key}"
  filename       = "${each.key}/cloudbuild.yaml"
  included_files = ["${each.key}/**"]

  # asia-notheast1だと制限がありビルドできなかったので、asia-east1に変更
  # https://cloud.google.com/build/docs/locations?hl=ja#restricted_regions_for_some_projects
  location        = "asia-east1"
  project         = var.project_id
  service_account = var.service_account

  github {
    owner = "matao0214"
    name  = "memo-app"
    push {
      branch = "^main$"
    }
  }
}
