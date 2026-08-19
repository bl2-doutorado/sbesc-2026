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
variable "vpc_cidr" {
  description = "CIDR block for VPC (overrides YAML)"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "List of availability zones (overrides YAML)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for all resources (overrides YAML)"
  type        = map(string)
  default     = {}
}
