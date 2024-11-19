resource "random_string" "eks_suffix" {
  length  = 8
  lower   = false
  special = false
}

resource "spacelift_worker_pool" "aws_eks" {
  csr      = base64encode(tls_cert_request.eks_cert.cert_request_pem)
  name     = "AWS EC2 Worker Pool Example - ${random_string.suffix.id}"
  space_id = spacelift_space.aws.id
}

# The private key and certificate are generated in Terraform for convenience in this demo.
# For improved security, we recommend that you create and manage them outside of Terraform.
# See https://docs.spacelift.io/concepts/worker-pools#setting-up.
resource "tls_private_key" "eks_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "eks_cert" {
  private_key_pem = tls_private_key.eks_private_key.private_key_pem

  subject {
    organization = local.spacelift_hostname
  }
}
