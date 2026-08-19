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
variable "vpc_name" {
  description = "VPC name (overrides YAML)"
  type        = string
  default     = ""
}

variable "subnet_cidr" {
  description = "Subnet CIDR (overrides YAML)"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Cluster name for subnet naming (overrides YAML)"
  type        = string
  default     = ""
}

variable "enable_private_cluster" {
  description = "Enable private cluster (overrides YAML)"
  type        = bool
  default     = null
}

variable "secondary_ranges" {
  description = "Secondary IP ranges for pods and services (overrides YAML). Auto-calculated if null."
  type = object({
    pods     = string
    services = string
  })
  default = null
}

variable "master_ipv4_cidr" {
  description = "CIDR for GKE master network (overrides YAML)"
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

variable "tags" {
  description = "Labels for all resources (overrides YAML)"
  type        = map(string)
  default     = {}
}
