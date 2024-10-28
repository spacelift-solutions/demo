# Configure Microsoft Azure provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

module "network" {
  source = "./modules/network"
  
  project_name           = var.project_name
  environment            = var.environment
  location               = var.location
  vnet_address_space     = var.vnet_address_space
  subnet_address_prefixes = var.subnet_address_prefixes
}

module "vm" {
  source = "./modules/vm"
  subscription_id = var.subscription_id

  project_name      = var.project_name
  environment       = var.environment
  location          = var.location
  vm_role           = var.vm_role
  vm_number         = var.vm_number
  resource_group_name = module.network.resource_group_name
  subnet_id         = module.network.subnet_id
  admin_password    = var.admin_password
}