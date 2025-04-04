module "datadog" {
  source  = "github.com/spacelift-io/terraform-spacelift-datadog?ref=logging-support"
  # version = "0.2.3"
  # insert the 1 required variable here
  dd_api_key = var.dd_api_key
  dd_site    = var.dd_site
}
