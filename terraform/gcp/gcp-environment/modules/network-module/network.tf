////////////////////////////
###---MODULE RESOURCES---###
////////////////////////////

# Create VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.gcp_environment_type}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
}

# Create subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.gcp_environment_type}-subnet"
  project       = var.project_id
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr

  # Enable flow logs for demo visibility
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  private_ip_google_access = true
}

# Create Cloud NAT for outbound internet access
resource "google_compute_router" "router" {
  name    = "${var.gcp_environment_type}-router"
  project = var.project_id
  region  = var.gcp_region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.gcp_environment_type}-nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Basic firewall rules
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.gcp_environment_type}-allow-internal"
  project = var.project_id
  network = google_compute_network.vpc.id

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }

  source_ranges = [var.subnet_cidr]
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.gcp_environment_type}-allow-health-checks"
  project = var.project_id
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

# Fix the reference to use the VPC we created
resource "google_compute_global_address" "private_ip_range" {
  name          = "${var.project_id}-private-ip-range-${random_id.network_suffix.hex}"  # Add unique suffix
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id

  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion
  }
}

resource "random_id" "network_suffix" {
  byte_length = 4
}