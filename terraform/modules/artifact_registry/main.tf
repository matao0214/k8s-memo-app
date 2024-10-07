data "google_client_config" "default" {}

resource "google_artifact_registry_repository" "default" {
  repository_id = "docker"
  location      = data.google_client_config.default.region
  format        = "DOCKER"
  cleanup_policies {
    id     = "delete-old-image"
    action = "KEEP"
    most_recent_versions {
      keep_count            = 1
      package_name_prefixes = []
    }
  }
  docker_config {
    immutable_tags = false
  }
}
