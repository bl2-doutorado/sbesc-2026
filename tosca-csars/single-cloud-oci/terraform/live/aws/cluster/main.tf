# Copyright (c) 2024
# AWS EKS Cluster - creates control plane only
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
  config  = yamldecode(file("${path.module}/../../envs/${var.env_name}.yaml"))
  aws     = local.config.aws
  cluster = local.config.cluster
  tags    = local.config.tags

  # Apply overrides or use YAML values
  cluster_name            = var.cluster_name != "" ? var.cluster_name : local.cluster.name
  kubernetes_version      = var.kubernetes_version != "" ? var.kubernetes_version : local.cluster.kubernetes_version
  subnet_ids              = length(var.subnet_ids) > 0 ? var.subnet_ids : try(local.aws.private_subnet_ids, [])
  vpc_id                  = var.vpc_id != "" ? var.vpc_id : try(local.aws.vpc_id, "")
  cluster_role_arn        = var.cluster_role_arn != "" ? var.cluster_role_arn : local.aws.cluster_role_arn
  endpoint_private_access = var.endpoint_private_access != null ? var.endpoint_private_access : try(local.cluster.endpoint_private_access, true)
  endpoint_public_access  = var.endpoint_public_access != null ? var.endpoint_public_access : try(local.cluster.endpoint_public_access, false)
}

# Provider
provider "aws" {
  region = local.aws.region
}

# EKS Cluster
module "eks_cluster" {
  source = "../../../modules/foundation/infra/aws/eks-cluster"

  cluster_name            = local.cluster_name
  kubernetes_version      = local.kubernetes_version
  cluster_role_arn        = local.cluster_role_arn
  subnet_ids              = local.subnet_ids
  endpoint_private_access = local.endpoint_private_access
  endpoint_public_access  = local.endpoint_public_access
  tags                    = local.tags
}
