variable "project_name" {
  description = "Name of the Project"
  type        = string
  default     = "spacelift-se-sandbox"
}

variable "environment" {
  description = "Deployment Environment - Sandbox, QA, or Prod"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "East US 2"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the Subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "vm_role" {
  description = "Role of the virtual machine (e.g., web, db)"
  type        = string
  default     = "web"
}

variable "vm_number" {
  description = "Instance number of the virtual machine"
  type        = number
  default     = 1
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_A1_v2"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}


variable "disable_password_auth" {
  description = "Disable password authentication"
  type        = bool
  default     = false
}

variable "subscription_id" {
  description = "The Subscription ID is required to run a plan or apply"
  type        = string
  sensitive   = true
}