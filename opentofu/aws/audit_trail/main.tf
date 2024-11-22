module "collector" {
  source = "github.com/spacelift-io-examples/terraform-aws-spacelift-events-collector"
  secret = var.audit_trail_secret
}
