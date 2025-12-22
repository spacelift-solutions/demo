resource "spacelift_named_webhook" "kals-flows-notification" {
  name     = "kals-flows-notifications"
  space_id = spacelift_space.aws_opentofu.id

  endpoint = "https://compassionate-hippopotamus-y7yl.endpoints.useflows.eu/spacelift/drift"
  enabled  = true
}
