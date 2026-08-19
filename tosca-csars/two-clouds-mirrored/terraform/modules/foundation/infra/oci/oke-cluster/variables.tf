# Copyright (c) 2024
# OKE Cluster Module variables

variable "compartment_ocid" {
  description = "OCI compartment OCID where the cluster will be created"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN where the cluster will be created"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster (e.g., v1.30.0)"
  type        = string

  validation {
    condition     = can(regex("^v\\d+\\.\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "Kubernetes version must be in format X.Y (e.g., v1.28.0, v1.29.0, v1.30.0)."
  }
}

variable "control_plane_subnet_id" {
  description = "OCID of the subnet for the cluster control plane"
  type        = string
}

variable "pods_subnet_id" {
  description = "OCID of the subnet for pods (optional, uses control_plane_subnet_id if not set)"
  type        = string
  default     = ""
}

variable "cluster_upgrade" {
  description = "Cluster upgrade channel: none, supported, or stable"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "supported", "stable"], var.cluster_upgrade)
    error_message = "Cluster upgrade must be one of: none, supported, stable."
  }
}

variable "kubernetes_dashboard_enabled" {
  description = "Enable Kubernetes Dashboard add-on"
  type        = bool
  default     = false
}

variable "tiller_is_enabled" {
  description = "Enable Tiller (Helm) in the cluster"
  type        = bool
  default     = false
}

variable "service_lb_subnet_id" {
  description = "Subnet OCID for LoadBalancer services (optional)"
  type        = string
  default     = ""
}

variable "pods_cidr" {
  description = "CIDR for pods (must not conflict with VCN)"
  type        = string
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.96.0.0/16"
}

variable "open_id_connect_discovery_url" {
  description = "OpenID Connect discovery URL for OIDC authentication (optional)"
  type        = string
  default     = ""
}

variable "endpoint_is_private" {
  description = "Make cluster endpoint accessible only via private network"
  type        = bool
  default     = true
}

variable "region" {
  description = "OCI region for the cluster"
  type        = string
  default     = "us-ashburn-1"
}

variable "freeform_tags" {
  description = "Freeform tags for the cluster"
  type        = map(string)
  default     = {}
}
