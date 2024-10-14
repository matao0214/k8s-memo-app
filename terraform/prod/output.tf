output "db_user_password" {
  value     = module.sql.db_user_password
  sensitive = true
}

output "db_instance_name" {
  value     = module.sql.db_instance_name
  sensitive = true
}

output "db_connection_name" {
  value     = module.sql.db_connection_name
  sensitive = true
}
