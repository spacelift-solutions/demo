
variable "project_name" {
  description = "Name of the Project"
  type = string
}

variable "environment" {
  description = "Name of the Environment - Sandbox, QA, or Prod"
  type = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default = "East US 2"
}
variable "vm_role" {
  description = "Role of the VM Resource"
  type = string
}

variable "vm_number" {
  description = "Number of the VM Resource"
  type = string
}

variable "vm_size" {
  description = "Size of the VM Resource"
  type = string
  default = "Standard_A1_v2"
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the Subnet"
  type        = string
}

variable "admin_username" {
  type = string
  description = "Azure Virtual Machine Admin Username"
  default = "cloudopsuser1"
}

variable "admin_password" {
  type        = string
  description = "Azure Virtual Machine Admin Password"
  sensitive   = true
}

variable "disable_password_auth" {
  description = "Disable password authentication"
  type        = bool
  default     = false
}

variable "subscription_id" {
  description = "The Subscription ID is required to run a plan or apply"
  type = string
  sensitive = true
}


