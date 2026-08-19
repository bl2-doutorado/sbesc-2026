# Copyright (c) 2024
# AWS EKS Node Pool - creates node groups only
# Reads config from live/envs/{env_name}.yaml, variables can override

terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 8.21.0"
    }
  }
}

# ============================================
# Load Config from YAML
# ============================================
locals {
  config = yamldecode(file("${path.module}/../../envs/${var.env_name}.yaml"))
  aws    = local.config.aws

  # Get node pools from YAML, filter by name if specified
  all_node_pools = try(local.config.node_pools.aws, [])
  node_pools     = var.node_pool_name != "" ? [for np in local.all_node_pools : np if np.name == var.node_pool_name] : local.all_node_pools
  node_pool      = length(local.node_pools) > 0 ? local.node_pools[0] : null

  # Apply overrides or use YAML values
  cluster_name  = var.cluster_name != "" ? var.cluster_name : local.config.cluster.name
  node_role_arn = var.node_role_arn != "" ? var.node_role_arn : local.aws.node_role_arn
  subnet_ids    = length(var.subnet_ids) > 0 ? var.subnet_ids : try(local.aws.private_subnet_ids, [])
  instance_type = var.instance_type != "" ? var.instance_type : try(local.node_pool.instance_type, "t3.medium")
  node_count    = var.node_count != null ? var.node_count : try(local.node_pool.count, 2)
  capacity_type = var.capacity_type != "" ? var.capacity_type : try(local.node_pool.capacity_type, "ON_DEMAND")
  labels        = try(local.node_pool.labels, {})
  tags          = local.config.tags
}

# Provider
provider "aws" {
  region = local.aws.region
}

# EKS Node Group
module "eks_node_group" {
  source = "../../../modules/foundation/infra/aws/eks-node-group"

  cluster_name    = local.cluster_name
  node_group_name = "${local.cluster_name}-${var.env_name}-${local.instance_type}"
  node_role_arn   = local.node_role_arn
  subnet_ids      = local.subnet_ids
  instance_type   = local.instance_type
  node_count      = local.node_count
  capacity_type   = local.capacity_type
  labels          = local.labels
  tags            = local.tags
}
