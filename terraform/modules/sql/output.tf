output "db_user_password" {
  value     = random_password.db_user.result
  sensitive = true
}

output "db_uesr_name" {
  value     = google_sql_user.default.name
  sensitive = true
}

output "four_bytes" {
  value     = random_id.four_bytes.hex
  sensitive = true
}

output "db_connection_name" {
  value     = google_sql_database_instance.example-cloudsql-instance.connection_name
  sensitive = true
}
