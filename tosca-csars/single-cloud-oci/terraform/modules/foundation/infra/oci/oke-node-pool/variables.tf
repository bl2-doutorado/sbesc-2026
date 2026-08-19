# Copyright (c) 2024
# OKE Node Pool Module variables

variable "compartment_ocid" {
  description = "OCI compartment OCID where the node pool will be created"
  type        = string
}

variable "cluster_id" {
  description = "OCID of the Kubernetes cluster"
  type        = string
}

variable "pool_name" {
  description = "Name of the node pool"
  type        = string
}

variable "node_shape" {
  description = "Shape of the nodes (e.g., VM.Standard3.Flex)"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the pool"
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1
    error_message = "Node count must be at least 1."
  }
}

variable "subnet_ids" {
  description = "List of subnet OCIDs for the nodes (private subnets recommended)"
  type        = list(string)
}

variable "availability_domain" {
  description = "Availability domain name for the nodes (e.g., GrCh:US-ASHBURN-AD-1)"
  type        = string
}

variable "node_labels" {
  description = "Kubernetes labels to apply to all nodes in the pool"
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "Kubernetes taints to apply to all nodes in the pool"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "memory_in_gb" {
  description = "Amount of memory in GB for flexible shapes (optional, uses shape default if not set)"
  type        = number
  default     = null
}

variable "ocpus" {
  description = "Number of OCPUs for flexible shapes (optional, uses shape default if not set)"
  type        = number
  default     = null
}

variable "source_type" {
  description = "Source type for nodes: 'OKE' or 'IMAGE'"
  type        = string
  default     = "OKE"

  validation {
    condition     = contains(["OKE", "IMAGE"], var.source_type)
    error_message = "Source type must be 'OKE' or 'IMAGE'."
  }
}

variable "node_image_id" {
  description = "Custom image OCID (required if source_type is 'image')"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Kubernetes version for the nodes (defaults to cluster version)"
  type        = string
  default     = ""
}

variable "freeform_tags" {
  description = "Freeform tags for the node pool"
  type        = map(string)
  default     = {}
}