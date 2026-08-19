# Copyright (c) 2024
# AWS Live Environment - Wrapper module
# Reads env_name and loads config from live/envs/{env_name}.yaml

terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 8.21.0"
    }
  }
}

# Environment name variable
variable "env_name" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

# Load environment config
locals {
  config = yamldecode(file("${path.module}/../envs/${var.env_name}.yaml"))

  # Cloud enablement
  clouds = try(local.config.clouds, { aws = true, gcp = false, oci = false })

  # AWS-specific configuration
  aws_config = local.config.aws
  region     = local.aws_config.region

  # Cluster configuration
  cluster = local.config.cluster

  # Node pools configuration (AWS-specific)
  node_pools = try(local.config.node_pools.aws, [])

  # Tags
  tags = local.config.tags
}

# Provider configuration
provider "aws" {
  region = local.region
}

# Network Module
module "network" {
  source = "../../modules/foundation/infra/aws/network"

  vpc_cidr           = try(local.aws_config.vpc_cidr, "10.0.0.0/16")
  environment        = var.env_name
  project            = local.tags.Project
  region             = local.region
  availability_zones = try(local.aws_config.availability_zones, ["${local.region}a", "${local.region}b", "${local.region}c"])

  tags = local.tags
}

# EKS Cluster
module "cluster" {
  source = "./cluster"

  env_name                = var.env_name
  cluster_name            = local.cluster.name
  kubernetes_version      = local.cluster.kubernetes_version
  subnet_ids              = module.network.private_subnet_ids
  vpc_id                  = module.network.vpc_id
  cluster_role_arn        = local.aws_config.cluster_role_arn
  endpoint_private_access = try(local.cluster.endpoint_private_access, true)
  endpoint_public_access  = try(local.cluster.endpoint_public_access, false)
  tags                    = local.tags
}

# Node Pools
module "node_pools" {
  source = "./node-pool"

  for_each = { for np in local.node_pools : np.name => np }

  env_name      = var.env_name
  cluster_name  = module.cluster.cluster_name
  node_role_arn = local.aws_config.node_role_arn
  subnet_ids    = module.network.private_subnet_ids
  instance_type = each.value.instance_type
  node_count    = each.value.count
  capacity_type = try(each.value.capacity_type, "ON_DEMAND")
  labels        = try(each.value.labels, {})
  tags          = local.tags
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.cluster.cluster_id
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.cluster.cluster_endpoint
}

output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = module.cluster.kubeconfig_command
}

output "node_group_names" {
  description = "Node group names"
  value       = [for np in module.node_pools : np.node_group_name]
}

output "node_names" {
  description = "Node names for workload mapping"
  value       = flatten([for np in module.node_pools : np.node_names])
}
