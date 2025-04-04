////////////////////////////
###---MODULE RESOURCES---###
////////////////////////////

# Create GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.gcp_environment_type}-gke-cluster"
  location = var.cluster_location
  project  = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  # Network configuration
  network    = var.network_name
  subnetwork = var.subnet_name
  # Setting protection to false for dynamic testing
  deletion_protection = false

  # Basic Auth disabled for security
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # IP allocation policy for VPC-native cluster
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Configure private cluster settings
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

}

# Create managed node pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.gcp_environment_type}-node-pool"
  location   = var.cluster_location
  cluster    = google_container_cluster.primary.name
  project    = var.project_id
  node_count = var.node_count

  node_config {
    preemptible  = true # Cost optimization for demo
    machine_type = var.machine_type

    disk_size_gb = 100
    disk_type    = "pd-standard" # 

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = var.gke_service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = var.gcp_environment_type
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  # Enable auto-repair and auto-upgrade for the node pool
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Create firewall rule for master access if necessary (e.g., to allow SSH into nodes for troubleshooting)
resource "google_compute_firewall" "allow_master_access" {
  name    = "${var.gcp_environment_type}-allow-master-access"
  network = var.network_name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["10250", "443"]
  }

  source_ranges = ["172.16.0.0/28"] # Adjust CIDR range to match your master nodes if needed

  target_tags = ["${var.gcp_environment_type}-gke-master"]
}
