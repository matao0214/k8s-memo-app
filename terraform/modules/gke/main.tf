data "google_client_config" "default" {}

resource "google_container_cluster" "default" {
  name = "example-autopilot-cluster"

  location                 = data.google_client_config.default.region
  enable_autopilot         = true
  enable_l4_ilb_subsetting = true

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    stack_type                    = "IPV4_IPV6"
    services_secondary_range_name = var.services_secondary_range_name
    cluster_secondary_range_name  = var.cluster_secondary_range_name
  }

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}
