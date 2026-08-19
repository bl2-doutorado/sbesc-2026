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

variable "machine_type" {
  description = "Machine type (overrides YAML)"
  type        = string
  default     = ""
}

variable "node_count" {
  description = "Number of nodes (overrides YAML)"
  type        = number
  default     = null
}

variable "node_pool_name" {
  description = "Node pool name (overrides YAML - selects which pool from list)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Labels for all resources (overrides YAML)"
  type        = map(string)
  default     = {}
}
