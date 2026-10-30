resource "spacelift_named_webhook" "kals-flows-notification" {
  name     = "kals-flows-notifications"
  space_id = var.aws_opentofu_space_id

  endpoint = "https://compassionate-hippopotamus-y7yl.endpoints.useflows.eu/spacelift/drift"
  enabled  = true
}
