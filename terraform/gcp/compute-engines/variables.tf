variable "project_id" {
  description = "The GCP project ID where the instance will be created."
  type        = string
}

variable "region" {
  description = "The GCP region for the instance."
  type        = string
  default     = locals.gcp_region
}

variable "zone" {
  description = "The GCP zone to deploy the instance."
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "The name of the Compute Engine instance."
  type        = string
  default     = "windows-instance"
}

variable "machine_type" {
  description = "The machine type to use for the instance."
  type        = string
  default     = "n1-standard-2"
}

variable "windows_image" {
  description = "The Windows image to use for the instance. This should be a public image from Google or a custom image you have created."
  type        = string
  # Public Windows 2019 image:
  default = "projects/windows-cloud/global/images/family/windows-2019"
}

variable "disk_size" {
  description = "The boot disk size (in GB) for the instance."
  type        = number
  default     = 50
}

variable "disk_type" {
  description = "The type of boot disk (e.g., pd-standard, pd-ssd)."
  type        = string
  default     = "pd-standard"
}

variable "network" {
  description = "The VPC network in which to create the instance."
  type        = string
  default     = "default"
}

variable "instance_tags" {
  description = "A list of tags to attach to the instance (useful for firewall rules or network tagging)."
  type        = list(string)
  default     = ["win", "demo", "testing"]
}
