variable "name" {
  description = "Tenant name. Used for the namespace, service account and IAM role names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]{0,40}[a-z0-9])?$", var.name))
    error_message = "name must be a lowercase DNS label (a-z, 0-9, '-') of at most 42 characters."
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster the tenant runs on"
  type        = string
}

variable "labels" {
  description = "Extra labels added to the tenant namespace"
  type        = map(string)
  default     = {}
}

variable "resource_quota" {
  description = "Total resources the namespace may request. Set to null to skip the ResourceQuota."
  type = object({
    requests_cpu    = optional(string, "4")
    requests_memory = optional(string, "8Gi")
    limits_cpu      = optional(string, "8")
    limits_memory   = optional(string, "16Gi")
    pods            = optional(string, "50")
    pvcs            = optional(string, "10")
    storage         = optional(string, "100Gi")
    load_balancers  = optional(string, "2")
  })
  default = {}
}

variable "container_defaults" {
  description = "Default requests and limits applied to containers that don't set their own"
  type = object({
    request_cpu    = optional(string, "100m")
    request_memory = optional(string, "128Mi")
    limit_cpu      = optional(string, "500m")
    limit_memory   = optional(string, "512Mi")
  })
  default = {}
}

variable "network_policy" {
  description = <<-EOT
    Ingress isolation for the namespace. When enabled, pods only accept traffic
    from their own namespace, the namespaces listed in allowed_namespaces, and
    the CIDRs in allowed_cidrs (e.g. the VPC CIDR so ALBs in IP mode can reach pods).
    Egress is not restricted.
  EOT
  type = object({
    enabled            = optional(bool, true)
    allowed_namespaces = optional(list(string), ["kube-system", "prometheus"])
    allowed_cidrs      = optional(list(string), [])
  })
  default = {}
}

variable "admin_groups" {
  description = "Kubernetes groups granted the built-in 'admin' role in the tenant namespace"
  type        = list(string)
  default     = []
}

variable "iam_policy_arns" {
  description = "IAM policy ARNs attached to the tenant's IRSA role. The role is only created when this or iam_policy_json is set."
  type        = list(string)
  default     = []
}

variable "iam_policy_json" {
  description = "Inline IAM policy document for the tenant's IRSA role"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to AWS resources"
  type        = map(string)
  default     = {}
}
