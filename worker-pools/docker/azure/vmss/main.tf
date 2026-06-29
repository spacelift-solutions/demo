# SSH key for admin access to the VMSS instances (generated for demo convenience).
resource "tls_private_key" "admin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "worker_pool_azure_vmss" {
  source = "github.com/spacelift-io/terraform-azure-spacelift-workerpool?ref=v3.0.0"

  admin_username   = var.admin_username
  admin_public_key = base64encode(tls_private_key.admin_ssh.public_key_openssh)

  # The worker pool credentials are sourced from the admin stack outputs and exported
  # so the Spacelift launcher on each VM can register with the pool.
  configuration = <<-EOT
    export SPACELIFT_TOKEN="${var.worker_pool_config}"
    export SPACELIFT_POOL_PRIVATE_KEY="${var.worker_pool_private_key}"
    export SPACELIFT_SENSITIVE_OUTPUT_UPLOAD_ENABLED=true
  EOT

  resource_group = azurerm_resource_group.workers
  subnet_id      = azurerm_subnet.workers.id
  worker_pool_id = var.worker_pool_id

  name_prefix = "sp5ft-demo"
  vmss_sku    = var.vmss_sku

  # Autoscaler keeps a minimum of one warm worker so demo runs start instantly.
  autoscaling_configuration = {
    max_create    = 2
    max_terminate = 1
    scale = {
      min = var.worker_pool_min_size
      max = var.worker_pool_max_size
    }
  }

  spacelift_api_credentials = {
    api_key_id       = var.spacelift_api_key_id
    api_key_secret   = var.spacelift_api_key_secret
    api_key_endpoint = "${var.spacelift_api_key_endpoint}/graphql"
  }

  tags = {
    Environment = "demo"
    ManagedBy   = "spacelift"
  }
}
