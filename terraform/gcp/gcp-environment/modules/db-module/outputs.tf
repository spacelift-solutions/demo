# Missing instance_id reference in outputs.tf
output "sql_instance_name" {
  value = google_sql_database_instance.main.name
  description = "The name of the SQL instance"
}

output "db_name_suffix" {
  value = random_id.db_name_suffix.hex
}
