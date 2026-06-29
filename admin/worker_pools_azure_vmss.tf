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
