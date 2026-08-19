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

variable "subnet_ids" {
  description = "Subnet IDs (overrides YAML - typically from network output)"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID (overrides YAML - typically from network output)"
  type        = string
  default     = ""
}

variable "cluster_role_arn" {
  description = "IAM role ARN for cluster (overrides YAML)"
  type        = string
  default     = ""
}

variable "endpoint_private_access" {
  description = "Enable private endpoint (overrides YAML)"
  type        = bool
  default     = null
}

variable "endpoint_public_access" {
  description = "Enable public endpoint (overrides YAML)"
  type        = bool
  default     = null
}
