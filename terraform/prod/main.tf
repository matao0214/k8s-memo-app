module "network" {
  source = "../modules/network"
}

module "gke" {
  source                        = "../modules/gke"
  network                       = module.network.default_id
  subnetwork                    = module.network.subnetwork_default_id
  services_secondary_range_name = module.network.services_secondary_range_name
  cluster_secondary_range_name  = module.network.cluster_secondary_range_name
}

module "artifact_registry_repository" {
  source = "../modules/artifact_registry"
}

module "sql" {
  source                      = "../modules/sql"
  db_name                     = "example-cloudsql-instance"
  db_deletion_protection      = false
  db_settings_edition         = "ENTERPRISE"
  db_settings_tier            = "db-f1-micro"
  db_settings_pricing_plan    = "PER_USE"
  db_settings_disk_size       = 10
  db_settings_disk_type       = "PD_HDD"
  db_settings_disk_autoresize = false
}
