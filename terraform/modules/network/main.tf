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
