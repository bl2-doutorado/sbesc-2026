# ============================================
# Core Variables
# ============================================
variable "env_name" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

# ============================================
# Override Variables (optional - overrides YAML)
# ============================================
variable "cluster_name" {
  description = "Cluster name (overrides YAML)"
  type        = string
  default     = ""
}

variable "compartment_ocid" {
  description = "OCI compartment OCID (overrides YAML)"
  type        = string
  default     = ""
}

variable "vcn_id" {
  description = "VCN OCID (overrides YAML - typically from network output)"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Kubernetes version (overrides YAML)"
  type        = string
  default     = ""
}

variable "control_plane_subnet_id" {
  description = "Control plane subnet OCID (overrides YAML - typically from network output)"
  type        = string
  default     = ""
}

variable "service_lb_subnet_id" {
  description = "Load balancer subnet OCID (overrides YAML)"
  type        = string
  default     = ""
}

variable "endpoint_is_private" {
  description = "Use private endpoint (overrides YAML)"
  type        = bool
  default     = null
}

variable "tags" {
  description = "Tags for all resources (overrides YAML)"
  type        = map(string)
  default     = {}
}
