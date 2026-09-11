# Spacelift needs a 2xx from the endpoint on save; it comes from a child stack.
resource "spacelift_audit_trail_webhook" "spacelift_audit_trail" {
  count = var.audit_trail_endpoint == "" ? 0 : 1

  endpoint     = var.audit_trail_endpoint
  enabled      = true
  secret       = var.audit_trail_secret
  include_runs = true
}
