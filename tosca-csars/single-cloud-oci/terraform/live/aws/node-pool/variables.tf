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

variable "node_role_arn" {
  description = "IAM role ARN for nodes (overrides YAML)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs (overrides YAML - typically from network output)"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "EC2 instance type (overrides YAML)"
  type        = string
  default     = ""
}

variable "node_count" {
  description = "Number of nodes (overrides YAML)"
  type        = number
  default     = null
}

variable "capacity_type" {
  description = "Capacity type: ON_DEMAND or SPOT (overrides YAML)"
  type        = string
  default     = ""
}

variable "node_pool_name" {
  description = "Node pool name (overrides YAML - selects which pool from list)"
  type        = string
  default     = ""
}
