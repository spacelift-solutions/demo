resource "spacelift_worker_pool" "gcp_ce_worker" {
  csr      = base64encode(tls_cert_request.primary_ce_worker.cert_request_pem)
  name     = "Compute Engine Worker Pool - WinRM Demo"
  space_id = "root"

}

# The private key and certificate are generated in Terraform for convenience in this demo.
# For improved security, we recommend that you create and manage them outside of Terraform.
# See https://docs.spacelift.io/concepts/worker-pools#setting-up.
resource "tls_private_key" "primary_ce_worker" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "primary_ce_worker" {
  private_key_pem = tls_private_key.primary_ce_worker.private_key_pem

  subject {
    organization = local.spacelift_hostname
  }
}
