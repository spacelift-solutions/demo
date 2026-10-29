output "admin_role_id" {
  description = "Administrative role assigned to the demo stacks."
  value       = spacelift_role.admin.id
}
