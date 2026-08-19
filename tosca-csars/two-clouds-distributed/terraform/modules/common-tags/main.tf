# Copyright (c) 2024
# Tag normalization logic for AWS, GCP, and OCI

locals {
  # Base tags always included
  base_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  # Optional cost center tag
  cost_center_tags = var.cost_center != "" ? { CostCenter = var.cost_center } : {}

  # Merge base tags, cost center, and extra tags
  all_tags = merge(local.base_tags, local.cost_center_tags, var.extra_tags)

  # AWS tags format: list of objects [{Key = ..., Value = ...}]
  aws_tags_list = [for k, v in local.all_tags : { Key = k, Value = v }]

  # GCP labels format: lowercase keys, underscores preserved
  gcp_labels_map = { for k, v in local.all_tags : lower(replace(k, " ", "_")) => v }

  # OCI freeform tags format: preserve key casing
  oci_freeform_tags_map = local.all_tags
}