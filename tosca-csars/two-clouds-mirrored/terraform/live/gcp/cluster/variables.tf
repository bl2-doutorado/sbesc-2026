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

variable "kubernetes_version" {
  description = "Kubernetes version (overrides YAML)"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet self-link (overrides YAML - typically from network output)"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "VPC name (overrides YAML)"
  type        = string
  default     = ""
}

variable "private_cluster" {
  description = "Enable private cluster (overrides YAML)"
  type        = bool
  default     = null
}

variable "private_endpoint" {
  description = "Enable private endpoint (overrides YAML). Set false for external access."
  type        = bool
  default     = null
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for GKE master network (overrides YAML)"
  type        = string
  default     = ""
}

variable "master_authorized_networks" {
  description = "CIDR blocks authorized to access GKE master (overrides YAML)"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = null
}

variable "node_locations" {
  description = "List of zones for nodes (overrides YAML). Empty = all zones in region."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Labels for all resources (overrides YAML)"
  type        = map(string)
  default     = {}
}
