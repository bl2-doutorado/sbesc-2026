# Copyright (c) 2024
# Common tags module - provides provider-specific tag formats

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project" {
  description = "Project name for resource identification"
  type        = string

  validation {
    condition     = length(var.project) > 0
    error_message = "Project name cannot be empty."
  }
}

variable "cost_center" {
  description = "Cost center for chargeback tracking (optional)"
  type        = string
  default     = ""
  nullable    = true
}

variable "extra_tags" {
  description = "Additional tags to apply to all resources (optional)"
  type        = map(string)
  default     = {}
}