
# Create a Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.project_name}-${var.environment}-${var.vm_role}${var.vm_number}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.project_name}-${var.environment}-${var.vm_role}${var.vm_number}-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.project_name}-${var.environment}-${var.vm_role}${var.vm_number}-vm"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  network_interface_ids           = [azurerm_network_interface.nic.id]
  size                            = var.vm_size
  computer_name                   = "${var.project_name}-${var.environment}-${var.vm_role}-${var.vm_number}"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = var.disable_password_auth

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.project_name}-${var.environment}-${var.vm_role}${var.vm_number}-osdisk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
