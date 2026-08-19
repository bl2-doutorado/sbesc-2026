# Copyright (c) 2024
# GKE Node Pool Module variables

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "pool_name" {
  description = "Name of the node pool"
  type        = string
}

variable "region" {
  description = "GCP region for the node pool"
  type        = string
}

variable "machine_type" {
  description = "GCP machine type for the nodes (e.g., e2-standard-8)"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the pool"
  type        = number

  validation {
    condition     = var.node_count >= 1
    error_message = "Node count must be at least 1."
  }
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Boot disk type: pd-standard, pd-ssd, pd-balanced"
  type        = string
  default     = "pd-standard"
}

variable "labels" {
  description = "Kubernetes labels to apply to all nodes in the pool"
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "Kubernetes taints to apply to all nodes in the pool"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "tags" {
  description = "Resource labels for the node pool"
  type        = map(string)
  default     = {}
}

variable "node_service_account_email" {
  description = "Email of the service account for GKE nodes. If empty, uses the default compute service account."
  type        = string
  default     = ""
}
