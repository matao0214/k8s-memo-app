data "google_client_config" "default" {}

resource "google_artifact_registry_repository" "default" {
  repository_id = "docker"
  location      = data.google_client_config.default.region
  format        = "DOCKER"
  cleanup_policies {
    id     = "delete-any"
    action = "DELETE"
    condition {
      tag_state = "ANY"
    }
  }
  cleanup_policies {
    id     = "keep-latest"
    action = "KEEP"
    most_recent_versions {
      keep_count = 1
    }
  }
  docker_config {
    immutable_tags = false
  }
}
