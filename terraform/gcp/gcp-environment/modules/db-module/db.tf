///////////////////
###--DB MODULE--###
///////////////////

# Random suffix for unique DB instance names
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Generate random password for database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create Secret Manager secret
resource "google_secret_manager_secret" "db_password" {
  secret_id = "${var.environment_type}-db-password"
  project   = var.project_id

  replication {
    auto {
      # Default replication
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Store the password in Secret Manager
resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

# Create a Cloud SQL instance
resource "google_sql_database_instance" "main" {
  name             = "${var.environment}-db-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_14"
  project          = var.project_id
  region           = var.region

  settings {
    tier = var.db_tier
    
    ip_configuration {
      ipv4_enabled    = true
      private_network = var.network_id
    }

    backup_configuration {
      enabled = true
      point_in_time_recovery_enabled = true
    }

    maintenance_window {
      day  = 7  # Sunday
      hour = 3  # 3 AM
    }

    # Demo-grade settings
    disk_size = 10  # minimum size
    disk_type = "PD_SSD"
    
    database_flags {
      name  = "max_connections"
      value = "100"
    }
  }

  deletion_protection = false  # Set to false for demo purposes
}

# Create a database
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# Create a user with the generated password
resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.main.name
  password = random_password.db_password.result
  project  = var.project_id
}

# Grant access to the secret
resource "google_secret_manager_secret_iam_binding" "secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members   = var.secret_accessors
}