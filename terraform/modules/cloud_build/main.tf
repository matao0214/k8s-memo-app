locals {
  repo_components = [
    "frontend",
    "api",
  ]
}

resource "google_cloudbuild_trigger" "memo-app" {
  for_each = toset(local.repo_components)

  # memo-app-${変数}の形式でトリガー名を設定
  name           = "memo-app-${each.key}"
  filename       = "cloud_build/${each.key}.yaml"
  included_files = ["${each.key}/**", "cloud_build/${each.key}.yaml"]

  # asia-notheast1だと制限がありビルドできなかったので、asia-east1に変更
  # https://cloud.google.com/build/docs/locations?hl=ja#restricted_regions_for_some_projects
  location        = "asia-east1"
  project         = var.project_id
  service_account = var.service_account

  repository_event_config {
    repository = google_cloudbuildv2_repository.my-repository.id
    push {
      branch       = "^main$"
      invert_regex = false
    }
  }
}

resource "google_secret_manager_secret" "github-token-secret" {
  project   = var.project_id
  secret_id = "github-token-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github-token-secret-version" {
  secret      = google_secret_manager_secret.github-token-secret.id
  secret_data = trimspace(file("../modules/cloud_build/my-github-token.txt"))
}

data "google_project" "my_project" {
  project_id = var.project_id
}

data "google_iam_policy" "p4sa-secretAccessor" {
  binding {
    role = "roles/secretmanager.secretAccessor"

    members = [
      "serviceAccount:service-${data.google_project.my_project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
    ]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  secret_id   = google_secret_manager_secret.github-token-secret.secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "my-connection" {
  project  = var.project_id
  location = "asia-east1"
  name     = "my-repo-connection"

  github_config {
    app_installation_id = tonumber(trimspace(file("../modules/cloud_build/my-github-app-installation-id.txt")))
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "my-repository" {
  location          = "asia-east1"
  name              = "memo-app"
  parent_connection = google_cloudbuildv2_connection.my-connection.name
  remote_uri        = trimspace(file("../modules/cloud_build/my-github-repo-url.txt"))
}
