# Copyright (c) 2024
# GCP Network Module variables

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the private subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "secondary_ranges" {
  description = "Secondary IP ranges for pods and services. Auto-calculated from subnet_cidr if null."
  type = object({
    pods     = string
    services = string
  })
  default = null
}

variable "enable_private_cluster" {
  description = "Enable private cluster firewall rules"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the GKE cluster (for firewall rules)"
  type        = string
  default     = ""
}

variable "master_ipv4_cidr" {
  description = "CIDR range for GKE master (e.g., 172.16.0.0/28)"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "CIDR blocks authorized to access GKE master endpoint"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "tags" {
  description = "Additional labels for resources"
  type        = map(string)
  default     = {}
}
