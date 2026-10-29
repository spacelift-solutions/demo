resource "spacelift_context_attachment" "monitoring_admin" {
  context_id = module.contexts.context_ids.monitoring
  stack_id   = data.spacelift_current_stack.admin.id
  priority   = 0
}

resource "spacelift_context_attachment" "monitoring_stack" {
  context_id = module.contexts.context_ids.monitoring
  stack_id   = module.stack_gcp_monitoring.id
  priority   = 0
}
