data "google_client_config" "default" {}

resource "google_sql_database_instance" "example-cloudsql-instance" {
  database_version    = "POSTGRES_16"
  region              = data.google_client_config.default.region
  name                = var.db_name
  project             = data.google_client_config.default.project
  deletion_protection = var.db_deletion_protection
  settings {
    edition         = var.db_settings_edition
    tier            = var.db_settings_tier
    pricing_plan    = var.db_settings_pricing_plan
    disk_size       = var.db_settings_disk_size
    disk_type       = var.db_settings_disk_type
    disk_autoresize = var.db_settings_disk_autoresize
  }
}
