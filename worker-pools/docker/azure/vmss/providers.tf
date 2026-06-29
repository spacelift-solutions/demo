terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.42"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Credentials are injected at runtime by the attached Spacelift Azure integration
# ("Spacelift Solutions", id 01KAEB7BTPH5CZZ8Y4JRXA9NS9) via ARM_* environment variables.
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}
