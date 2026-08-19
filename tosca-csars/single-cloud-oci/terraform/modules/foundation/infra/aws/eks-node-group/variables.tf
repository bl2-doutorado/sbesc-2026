# Copyright (c) 2024
# EKS Node Group Module variables

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the IAM role for the node group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the node group"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for the nodes (e.g., c5.2xlarge)"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the group"
  type        = number

  validation {
    condition     = var.node_count >= 1
    error_message = "Node count must be at least 1."
  }
}

variable "capacity_type" {
  description = "Capacity type: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "Capacity type must be ON_DEMAND or SPOT."
  }
}

variable "labels" {
  description = "Kubernetes labels to apply to all nodes in the group"
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "Kubernetes taints to apply to all nodes in the group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "tags" {
  description = "Tags for the node group"
  type        = map(string)
  default     = {}
}
