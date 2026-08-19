# Copyright (c) 2024
# GKE Cluster Module variables

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster (e.g., 1.31)"
  type        = string
  default     = "1.31"
}

variable "region" {
  description = "GCP region for the cluster"
  type        = string
}

variable "node_locations" {
  description = "List of zones within the region to create nodes. If empty, nodes will be created in all zones of the region."
  type        = list(string)
  default     = []
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet self links for the cluster"
  type        = list(string)
}

variable "private_cluster" {
  description = "Enable private cluster (private nodes)"
  type        = bool
  default     = true
}

variable "private_endpoint" {
  description = "Enable private endpoint (master accessible only from internal network). Set false for external access."
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the master network (required for private clusters)"
  type        = string
  default     = "172.16.0.0/28"
}

variable "pods_range_name" {
  description = "Name of the secondary range for pods"
  type        = string
  default     = "pods"
}

variable "services_range_name" {
  description = "Name of the secondary range for services"
  type        = string
  default     = "services"
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks authorized to access the master endpoint"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "tags" {
  description = "Resource labels for the GKE cluster"
  type        = map(string)
  default     = {}
}
