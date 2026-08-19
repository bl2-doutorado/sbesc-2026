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
variable "compartment_ocid" {
  description = "OCI compartment OCID (overrides YAML)"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for VCN (overrides YAML)"
  type        = string
  default     = ""
}

variable "availability_domain_count" {
  description = "Number of ADs for subnets (overrides YAML)"
  type        = number
  default     = null
}
