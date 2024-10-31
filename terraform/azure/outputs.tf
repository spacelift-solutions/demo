output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = module.network.resource_group_name
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.network.vnet_id
}

output "subnet_id" {
  description = "ID of the Subnet"
  value       = module.network.subnet_id
}

output "vm_id" {
  description = "ID of the Virtual Machine"
  value       = module.vm.vm_id
}

output "vm_private_ip" {
  description = "Public IP of the Virtual Machine"
  value       = module.vm.vm_private_ip
}