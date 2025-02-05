output "instance_ip" {
  description = "The public IP of the Windows instance."
  value       = google_compute_instance.windows_instance.network_interface[0].access_config[0].nat_ip
}
