# Copyright (c) 2024
# OCI Live Environment - Wrapper module
# Reads env_name and loads config from live/envs/{env_name}.yaml

terraform {
  required_version = "~> 1.9"

  required_providers {
    oci = {
      source  = "oracle/oci"
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
  clouds = try(local.config.clouds, { aws = false, gcp = false, oci = true })

  # OCI-specific configuration
  oci_config = local.config.oci
  region     = local.oci_config.region

  # Cluster configuration
  cluster = local.config.cluster

  # Node pools configuration (OCI-specific)
  node_pools = try(local.config.node_pools.oci, [])

  # Tags
  tags = local.config.tags
}

# Provider configuration
provider "oci" {
  region  = local.region
  version = ">= 8.21.0"
}

# Network Module
module "network" {
  source = "../../modules/foundation/infra/oci/network"

  vpc_cidr                  = try(local.oci_config.vpc_cidr, "10.0.0.0/16")
  environment               = var.env_name
  project                   = local.tags.Project
  region                    = local.region
  compartment_ocid          = local.oci_config.compartment_ocid
  availability_domain_count = try(local.oci_config.availability_domain_count, 3)
}

# OKE Cluster
module "cluster" {
  source = "./cluster"

  env_name                = var.env_name
  cluster_name            = local.cluster.name
  compartment_ocid        = local.oci_config.compartment_ocid
  vcn_id                  = module.network.vcn_id
  kubernetes_version      = local.cluster.kubernetes_version
  control_plane_subnet_id = module.network.private_subnet_ids[0]
  endpoint_is_private     = try(local.cluster.endpoint_is_private, true)
  service_lb_subnet_id    = module.network.public_subnet_ids[0]
  region                  = local.region
  tags                    = local.tags
}

# Node Pools
module "node_pools" {
  source = "./node-pool"

  for_each = { for np in local.node_pools : np.name => np }

  env_name            = var.env_name
  compartment_ocid    = local.oci_config.compartment_ocid
  cluster_id          = module.cluster.cluster_id
  availability_domain = each.value.availability_domain
  subnet_ids          = module.network.private_subnet_ids
  pool_name           = each.value.name
  node_shape          = each.value.instance_type
  node_count          = each.value.count
  memory_in_gb        = try(each.value.memory_gb, 16)
  ocpus               = try(each.value.ocpus, 1)
  node_labels         = try(each.value.labels, {})
  region              = local.region
  tags                = local.tags
}

# Outputs
output "vcn_id" {
  description = "ID of the VCN"
  value       = module.network.vcn_id
}

output "cluster_id" {
  description = "OCID of the OKE cluster"
  value       = module.cluster.cluster_id
}

output "cluster_name" {
  description = "Name of the OKE cluster"
  value       = module.cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.cluster.cluster_endpoint
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig"
  value       = module.cluster.kubeconfig_command
}

output "node_pool_ids" {
  description = "Node pool IDs"
  value       = [for np in module.node_pools : np.node_pool_id]
}
