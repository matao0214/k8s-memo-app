resource "google_service_account" "cloud_build" {
  account_id   = "cloud-build"
  display_name = "Cloud Build Service Account"
}

resource "google_project_iam_member" "cloud_build_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_build_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_sql_connect" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${google_service_account.cloud_sql_connect.email}"
}

resource "google_service_account" "cloud_sql_connect" {
  account_id   = "cloudsql-connect"
  display_name = "Cloud SQL Connect Service Account"
}

data "google_iam_policy" "cloud_sql_proxy" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    # ref: https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity?hl=ja#verify
    members = [
      "serviceAccount:${var.project_id}.svc.id.goog[default/cloud-sql-proxy]"
    ]
  }
}

resource "google_service_account_iam_policy" "cloud_sql_proxy" {
  service_account_id = google_service_account.cloud_sql_connect.name
  policy_data        = data.google_iam_policy.cloud_sql_proxy.policy_data
}
