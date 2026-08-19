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

variable "cluster_id" {
  description = "Cluster OCID (overrides YAML - typically from cluster output)"
  type        = string
  default     = ""
}

variable "availability_domain" {
  description = "Availability domain (overrides YAML)"
  type        = string
  default     = ""
}

variable "nodes_subnet_id" {
  description = "Private subnet OCID for nodes (overrides YAML - from network output)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet OCIDs (overrides nodes_subnet_id - typically not used directly)"
  type        = list(string)
  default     = []
}

variable "node_shape" {
  description = "Node shape (overrides YAML)"
  type        = string
  default     = ""
}

variable "node_count" {
  description = "Number of nodes (overrides YAML)"
  type        = number
  default     = null
}

variable "source_type" {
  description = "Source type for nodes: OKE or IMAGE (overrides YAML)"
  type        = string
  default     = ""
}

variable "node_image_id" {
  description = "Custom image OCID (overrides YAML - required if source_type is IMAGE)"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Kubernetes version for nodes (overrides YAML - should match cluster version)"
  type        = string
  default     = ""
}

variable "memory_in_gb" {
  description = "Memory in GB (overrides YAML)"
  type        = number
  default     = null
}

variable "ocpus" {
  description = "Number of OCPUs (overrides YAML)"
  type        = number
  default     = null
}

variable "node_pool_name" {
  description = "Node pool name (overrides YAML - selects which pool from list)"
  type        = string
  default     = ""
}

variable "node_labels" {
  description = "Kubernetes labels (overrides YAML)"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for all resources (overrides YAML)"
  type        = map(string)
  default     = {}
}
