variable "github_app_id" {
  type        = string
  description = "App ID used to authenticate the GitHub provider."
}

variable "github_app_installation_id" {
  type        = string
  description = "Installation ID used to authenticate the GitHub provider."
}

variable "import_existing_repository" {
  type        = bool
  description = "Whether to import an existing repository instead of creating one."
  default     = false
}

variable "repository_name" {
  type        = string
  description = "Name of the GitHub repository to create."

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]{1,100}$", var.repository_name))
    error_message = "The repository name must be 1-100 characters and contain only letters, numbers, periods, underscores, or hyphens."
  }
}

variable "repository_description" {
  type        = string
  description = "Description of the GitHub repository."
  default     = ""

  validation {
    condition     = length(var.repository_description) <= 350
    error_message = "The repository description cannot exceed 350 characters."
  }
}

variable "repository_visibility" {
  type        = string
  description = "Visibility of the GitHub repository."
  default     = "private"

  validation {
    condition     = contains(["private", "public", "internal"], var.repository_visibility)
    error_message = "The repository visibility must be private, public, or internal."
  }
}
