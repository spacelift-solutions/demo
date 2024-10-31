variable "project_name" {
  description = "Name of the Project"
  type        = string
}
variable "environment" {
  description = "Name of the Environment"
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
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the Subnet"
  type        = list(string)
}