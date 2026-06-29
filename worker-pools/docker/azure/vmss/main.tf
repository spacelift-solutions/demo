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

  # Static single-worker pool: one always-warm worker (ideal for live demos).
  # The module's autoscaler is intentionally not used here — it creates role
  # assignments for its Function App identity, which requires roleAssignments/write
  # that the Spacelift integration SP can't be granted under the subscription's
  # ABAC guardrails.
  non_autoscaled_vmss_instances = var.worker_count

  tags = {
    Environment = "demo"
    ManagedBy   = "spacelift"
  }
}
