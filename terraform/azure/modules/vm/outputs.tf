output "vm_id" {
  description = "The ID of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_private_ip" {
  description = "The public IP of the Virtual Machine"
  value       = azurerm_network_interface.nic.private_ip_address
}