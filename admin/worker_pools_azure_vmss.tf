resource "spacelift_worker_pool" "azure_vmss" {
  csr      = base64encode(tls_cert_request.azure_vmss.cert_request_pem)
  name     = "Azure VMSS Worker Pool - Demo"
  space_id = "root"
}

# The private key and certificate are generated in Terraform for convenience in this demo.
# For improved security, create and manage them outside of Terraform.
# See https://docs.spacelift.io/concepts/worker-pools#setting-up.
resource "tls_private_key" "azure_vmss" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "azure_vmss" {
  private_key_pem = tls_private_key.azure_vmss.private_key_pem

  subject {
    organization = local.spacelift_hostname
  }
}

# API key used by the VMSS autoscaler to query the worker pool queue and drain workers.
resource "spacelift_api_key" "azure_vmss_autoscaler" {
  name = "azure-vmss-autoscaler"
}

# Built-in system role for worker pool automation (SPACE_READ + WORKER_POOL_*).
data "spacelift_role" "worker_pool_controller" {
  slug = "worker-pool-controller"
}

resource "spacelift_role_attachment" "azure_vmss_autoscaler" {
  api_key_id = spacelift_api_key.azure_vmss_autoscaler.id
  role_id    = data.spacelift_role.worker_pool_controller.role_id
  space_id   = "root"
}
