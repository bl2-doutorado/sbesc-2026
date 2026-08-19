# Copyright (c) 2024
# EKS Cluster Module variables

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster (e.g., 1.31)"
  type        = string
  default     = "1.31"

  validation {
    condition     = can(regex("^1\\.(2[0-9]|3[0-9])$", var.kubernetes_version))
    error_message = "Kubernetes version must be in format 1.XX (e.g., 1.30, 1.31)."
  }
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster control plane ENIs"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster (optional)"
  type        = string
  default     = ""
}

variable "enabled_cluster_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "tags" {
  description = "Tags for the EKS cluster"
  type        = map(string)
  default     = {}
}
