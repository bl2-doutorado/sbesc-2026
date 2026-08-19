# Copyright (c) 2024
# OCI OKE Node Pool - creates node pools only
# Reads config from live/envs/{env_name}.yaml, variables can override

terraform {
  required_version = "~> 1.9"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 8.21.0"
    }
  }
}

# ============================================
# Load Config from YAML
# ============================================
locals {
  config = yamldecode(file("${path.module}/../../envs/${var.env_name}.yaml"))
  oci    = local.config.oci
  tags   = local.config.tags

  # Get node pools from YAML, filter by name if specified
  all_node_pools = try(local.config.node_pools.oci, [])
  node_pools     = var.node_pool_name != "" ? [for np in local.all_node_pools : np if np.name == var.node_pool_name] : local.all_node_pools
  node_pool      = length(local.node_pools) > 0 ? local.node_pools[0] : null

  # Determine subnet_ids: var.nodes_subnet_id > var.subnet_ids > YAML
  nodes_subnet_id = var.nodes_subnet_id != "" ? var.nodes_subnet_id : ""
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : (
    local.nodes_subnet_id != "" ? [local.nodes_subnet_id] : try(local.oci.private_subnet_ids, [])
  )

  # Apply overrides or use YAML values
  compartment_ocid    = var.compartment_ocid != "" ? var.compartment_ocid : local.oci.compartment_ocid
  cluster_id          = var.cluster_id != "" ? var.cluster_id : try(local.oci.cluster_id, "")
  availability_domain = var.availability_domain != "" ? var.availability_domain : try(local.node_pool.availability_domain, "")
  node_shape          = var.node_shape != "" ? var.node_shape : try(local.node_pool.instance_type, "VM.Standard.A1.Flex")
  node_count          = var.node_count != null ? var.node_count : try(local.node_pool.count, 1)
  kubernetes_version  = var.kubernetes_version != "" ? var.kubernetes_version : try(local.node_pool.kubernetes_version, try(local.config.cluster.kubernetes_version, ""))
  source_type         = var.source_type != "" ? var.source_type : try(local.node_pool.source_type, "OKE")
  node_image_id       = var.node_image_id != "" ? var.node_image_id : try(local.node_pool.image_id, "")
  memory_in_gb        = var.memory_in_gb != null ? var.memory_in_gb : try(local.node_pool.memory_gb, 16)
  ocpus               = var.ocpus != null ? var.ocpus : try(local.node_pool.ocpus, 1)
  node_labels         = length(var.node_labels) > 0 ? var.node_labels : try(local.node_pool.labels, {})
  tags_merged         = merge(local.tags, var.tags)
}

# Provider
provider "oci" {
  region = local.oci.region
  # version = ">= 8.21.0"
}

# OKE Node Pool Module
module "oke_node_pool" {
  source = "../../../modules/foundation/infra/oci/oke-node-pool"

  compartment_ocid    = local.compartment_ocid
  cluster_id          = local.cluster_id
  pool_name           = "${local.node_shape}-${var.env_name}"
  node_shape          = local.node_shape
  node_count          = local.node_count
  subnet_ids          = local.subnet_ids
  availability_domain = local.availability_domain
  kubernetes_version  = local.kubernetes_version
  source_type         = local.source_type
  node_image_id       = local.node_image_id
  memory_in_gb        = local.memory_in_gb
  ocpus               = local.ocpus
  node_labels         = local.node_labels
}
