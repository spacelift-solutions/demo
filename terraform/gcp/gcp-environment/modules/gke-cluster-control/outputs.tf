output "cluster_name" {
  description = "Name of the controlled cluster"
  value       = var.cluster_name
}

output "cluster_location" {
  description = "Location of the controlled cluster"
  value       = var.cluster_location
}

output "desired_state" {
  description = "Desired state that was requested"
  value       = var.desired_state
}

output "current_state" {
  description = "Current state of the cluster after operation"
  value       = data.external.cluster_status.result.state
}

output "current_node_count" {
  description = "Current number of nodes in the cluster"
  value       = data.external.cluster_status.result.node_count
}

output "cluster_status" {
  description = "Current cluster status from GKE API"
  value       = data.external.cluster_status.result.cluster_status
}

output "operation_timestamp" {
  description = "Timestamp of the last operation"
  value       = timestamp()
}