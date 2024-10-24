data "google_client_config" "default" {}

resource "random_id" "four_bytes" {
  byte_length = 4
}

resource "google_sql_database_instance" "example-cloudsql-instance" {
  database_version    = "POSTGRES_16"
  region              = data.google_client_config.default.region
  name                = var.db_instance_name
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

resource "google_sql_database" "default" {
  name     = "memo-app-${random_id.db_user.hex}"
  instance = google_sql_database_instance.example-cloudsql-instance.name
}

resource "random_password" "db_user" {
  length  = 16
  special = true
}

resource "random_id" "db_user" {
  byte_length = 4
}

resource "google_sql_user" "default" {
  name     = "postgres_user_${random_id.db_user.hex}"
  instance = google_sql_database_instance.example-cloudsql-instance.name
  password = random_password.db_user.result

  depends_on = [google_sql_database_instance.example-cloudsql-instance]
}
