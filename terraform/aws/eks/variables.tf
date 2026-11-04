variable "aws_region" {
  description = "AWS region"
}

variable "cluster_name" {
  description = "Name of the EKS Cluster"
}

variable "cluster_version" {
  description = "Kubernetes version of the EKS Cluster"
}

variable "vpc_id" {
  description = "ID of the VPC"
}

variable "subnet_ids" {
  description = "List of private subnets"
  type        = list(string)
}

variable "cluster_admin_role_arns" {
  description = "Map of IAM role ARNs to grant cluster admin access. Key is a name identifier, value is the role ARN."
  type        = map(string)
  default     = {}
}

variable "node_cpu_target_utilization" {
  description = "Average CPU utilisation (percent) the node group target-tracking policy maintains. Scale-out above, scale-in below."
  type        = number
  default     = 70

  validation {
    condition     = var.node_cpu_target_utilization > 0 && var.node_cpu_target_utilization <= 100
    error_message = "node_cpu_target_utilization must be between 1 and 100."
  }
}

variable "node_cpu_scaling_warmup_seconds" {
  description = "Seconds a newly launched node is excluded from the CPU metric before it counts toward the target."
  type        = number
  default     = 300
}

variable "node_cpu_disable_scale_in" {
  description = "When true the CPU policy only scales out and leaves scale-in to Cluster Autoscaler, which drains nodes safely first."
  type        = bool
  default     = true
}
