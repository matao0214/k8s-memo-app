data "google_client_config" "default" {}

resource "google_compute_network" "default" {
  name = "example-network"

  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "default" {
  name = "example-subnetwork"

  ip_cidr_range = "10.0.0.0/16"
  region        = data.google_client_config.default.region

  stack_type = "IPV4_IPV6"
  # ipv6_access_type = "INTERNAL" # Change to "EXTERNAL" if creating an external loadbalancer
  ipv6_access_type = "EXTERNAL"

  network = google_compute_network.default.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.1.0/24"
  }
}

resource "google_container_cluster" "default" {
  name = "example-autopilot-cluster"

  location                 = data.google_client_config.default.region
  enable_autopilot         = true
  enable_l4_ilb_subsetting = true

  network    = google_compute_network.default.id
  subnetwork = google_compute_subnetwork.default.id

  ip_allocation_policy {
    stack_type                    = "IPV4_IPV6"
    services_secondary_range_name = google_compute_subnetwork.default.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.default.secondary_ip_range[1].range_name
  }

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}

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
