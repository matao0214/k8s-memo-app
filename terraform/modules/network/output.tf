output "default_id" {
  value = google_compute_network.default.id
}

output "subnetwork_default_id" {
  value = google_compute_subnetwork.default.id
}

output "services_secondary_range_name" {
  value = google_compute_subnetwork.default.secondary_ip_range[0].range_name
}

output "cluster_secondary_range_name" {
  value = google_compute_subnetwork.default.secondary_ip_range[1].range_name
}
