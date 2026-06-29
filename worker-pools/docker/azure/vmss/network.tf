# Dedicated resource group + network for the Azure demo worker pool.
resource "azurerm_resource_group" "workers" {
  name     = "rg-spacelift-demo-workers"
  location = var.location

  tags = {
    Environment = "demo"
    ManagedBy   = "spacelift"
  }
}

resource "azurerm_virtual_network" "workers" {
  name                = "vnet-spacelift-demo"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.workers.location
  resource_group_name = azurerm_resource_group.workers.name

  tags = azurerm_resource_group.workers.tags
}

resource "azurerm_subnet" "workers" {
  name                 = "snet-workers"
  resource_group_name  = azurerm_resource_group.workers.name
  virtual_network_name = azurerm_virtual_network.workers.name
  address_prefixes     = ["10.10.1.0/24"]
}
