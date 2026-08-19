# Copyright (c) 2024
# GKE Node Pool - creates node pools only
# Reads config from live/envs/{env_name}.yaml, variables can override

terraform {
  required_version = "~> 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.42.0"
    }
  }
}

# ============================================
# Load Config from YAML
# ============================================
locals {
  config = yamldecode(file("${path.module}/../../envs/${var.env_name}.yaml"))
  gcp    = local.config.gcp
  tags   = local.config.tags

  # Get node pools from YAML, filter by name if specified
  all_node_pools = try(local.config.node_pools.gcp, [])
  node_pools     = var.node_pool_name != "" ? [for np in local.all_node_pools : np if np.name == var.node_pool_name] : local.all_node_pools
  node_pool      = length(local.node_pools) > 0 ? local.node_pools[0] : null

  # Apply overrides or use YAML values
  cluster_name = var.cluster_name != "" ? var.cluster_name : local.config.cluster.name
  machine_type = var.machine_type != "" ? var.machine_type : try(local.node_pool.machine_type, "e2-standard-4")
  node_count   = var.node_count != null ? var.node_count : try(local.node_pool.count, 1)
  labels       = try(local.node_pool.labels, {})
  tags_merged  = merge(local.tags, var.tags)

  # Pool name: use YAML name if available, otherwise construct (max 40 chars)
  yaml_pool_name   = try(local.node_pool.name, "")
  constructed_name = "${var.env_name}-${local.machine_type}"

  # Truncate constructed name to 40 characters if needed
  pool_name = local.yaml_pool_name != "" ? local.yaml_pool_name : (
    length(local.constructed_name) > 40 ? substr(local.constructed_name, 0, 40) : local.constructed_name
  )
}

# Provider
provider "google" {
  project = local.gcp.project_id
  region  = local.gcp.region
}

# GKE Node Pool
module "gke_node_pool" {
  source = "../../../modules/foundation/infra/gcp/gke-node-pool"

  cluster_name = local.cluster_name
  pool_name    = local.pool_name
  region       = local.gcp.region
  machine_type = local.machine_type
  node_count   = local.node_count
  labels       = local.labels
  tags         = local.tags_merged
}
