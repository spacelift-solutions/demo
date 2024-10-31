////////////////////////////
###---MODULE RESOURCES---###
////////////////////////////

// Author: MG

// Anyone can add additional resources 
// With the modules, the regular "modular" approach of files is followed, due to the expected growing size.

# Random suffix for unique DB instance names
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Create a Cloud SQL instance
resource "google_sql_database_instance" "main" {
  name             = "${var.environment}-db-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_14" # Using PostgreSQL for this demo
  project          = var.project_id
  region           = var.region

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.network_id
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    maintenance_window {
      day  = 7 # Sunday
      hour = 3 # 3 AM
    }

    # Demo-grade settings
    disk_size = 10 # minimum size
    disk_type = "PD_SSD"

    database_flags {
      name  = "max_connections"
      value = "100"
    }
  }

  deletion_protection = false # Set to false for demo purposes
}

# Create a database
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# Create a user
resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.main.name
  password = var.db_password
  project  = var.project_id
}