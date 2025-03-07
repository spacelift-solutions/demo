###---COMPUTE ENGINES---###

// Every compute engine resource serves a different testing or demo purpose. 
// Anyone can add anything, as long as it serves our demo and testign purposes.

// WinRM CE Example //
resource "google_compute_instance" "windows_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = var.windows_image
      size  = var.disk_size
      type  = var.disk_type
    }
  }

  network_interface {
    network = var.network

    access_config {
      # Ephemeral public IP is automatically allocated when access_config is empty.
    }
  }


  # metadata = {
  #   # This metadata key is specific for Windows startup scripts (PowerShell).
  #   windows-startup-script-ps1 = var.startup_script
  # }

  tags = var.instance_tags
}