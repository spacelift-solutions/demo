resource "spacelift_context_attachment" "monitoring_admin" {
  context_id = var.monitoring_context_id
  stack_id   = var.admin_stack_id
  priority   = 0
}

resource "spacelift_context_attachment" "monitoring_stack" {
  context_id = var.monitoring_context_id
  stack_id   = var.monitoring_stack_id
  priority   = 0
}
