# Copyright (c) 2024
# GCP Live Environment - Wrapper module
# Reads env_name and loads config from live/envs/{env_name}.yaml

terraform {
  required_version = "~> 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.42.0"
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
  clouds = try(local.config.clouds, { aws = false, gcp = true, oci = false })

  # GCP-specific configuration
  gcp_config = local.config.gcp
  region     = local.gcp_config.region

  # Cluster configuration
  cluster = local.config.cluster

  # Node pools configuration (GCP-specific)
  node_pools = try(local.config.node_pools.gcp, [])

  # Tags
  tags = local.config.tags
}

# Provider configuration
provider "google" {
  project = local.gcp_config.project_id
  region  = local.region
}

# Network Module
module "network" {
  source = "../../modules/foundation/infra/gcp/network"

  vpc_name               = local.gcp_config.vpc_name
  project_id             = local.gcp_config.project_id
  region                 = local.region
  subnet_cidr            = try(local.gcp_config.subnet_cidr, "10.0.0.0/20")
  cluster_name           = local.cluster.name
  enable_private_cluster = try(local.cluster.private_cluster, true)

  tags = local.tags
}

# GKE Cluster
module "cluster" {
  source = "./cluster"

  env_name           = var.env_name
  cluster_name       = local.cluster.name
  kubernetes_version = local.cluster.kubernetes_version
  region             = local.region
  project_id         = local.gcp_config.project_id
  subnet_id          = module.network.subnet_id
  vpc_name           = module.network.vpc_name
  private_cluster    = try(local.cluster.private_cluster, true)
  tags               = local.tags
}

# Node Pools
module "node_pools" {
  source = "./node-pool"

  for_each = { for np in local.node_pools : np.name => np }

  env_name     = var.env_name
  cluster_name = module.cluster.cluster_name
  region       = local.region
  project_id   = local.gcp_config.project_id
  machine_type = each.value.machine_type
  node_count   = each.value.count
  labels       = try(each.value.labels, {})
  tags         = local.tags
}

# Outputs
output "vpc_name" {
  description = "Name of the VPC"
  value       = module.network.vpc_name
}

output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.cluster.cluster_endpoint
}

output "kubeconfig_command" {
  description = "Command to get cluster credentials"
  value       = module.cluster.kubeconfig_command
}

output "node_pool_names" {
  description = "Node pool names"
  value       = [for np in module.node_pools : np.pool_name]
}

output "node_names" {
  description = "Node names for workload mapping"
  value       = flatten([for np in module.node_pools : np.node_names])
}
