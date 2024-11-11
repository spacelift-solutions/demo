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
  secret_id = "${var.gcp_environment_type}-db-password"
  project   = var.project_id

  replication {
    auto {}
    # user_managed  {
    #   replicas {
    #     location = "europe-west2"
    #   }
    }

  labels = {
    environment = var.gcp_environment_type
    managed_by  = "terraform"
  }
}

# Store the password in Secret Manager
resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

# Reserve a range of IP addresses for VPC peering
resource "google_compute_global_address" "private_ip_range" {
  name          = "${var.project_id}-private-ip-range"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16  # Size of IP range for internal use
  network       = var.network_id
}

# Create a private services connection for VPC
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]

  depends_on = [
    google_compute_global_address.private_ip_range
  ]
}

# Create Cloud SQL instance
resource "google_sql_database_instance" "main" {
  name             = "${var.gcp_environment_type}-db-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_14"
  project          = var.project_id
  region           = var.gcp_region

  settings {
    tier       = var.db_tier
    disk_size  = 10            # Minimum size to reduce SSD requirements
    disk_type  = "PD_HDD" # Change to standard disk to avoid SSD quota

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    maintenance_window {
      day  = 7  # Sunday
      hour = 3  # 3 AM
    }

    database_flags {
      name  = "max_connections"
      value = "100"
    }
  }

  deletion_protection = false
  
  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

# Create a database in Cloud SQL
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# Create a user for Cloud SQL with the generated password
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
