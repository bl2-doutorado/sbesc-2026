# Copyright (c) 2024
# GCP Network - VPC and Subnets
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

  # Apply overrides or use YAML values
  vpc_name               = var.vpc_name != "" ? var.vpc_name : local.gcp.vpc_name
  subnet_cidr            = var.subnet_cidr != "" ? var.subnet_cidr : try(local.gcp.subnet_cidr, "10.0.0.0/20")
  cluster_name           = var.cluster_name != "" ? var.cluster_name : "${var.env_name}-cluster"
  enable_private_cluster = var.enable_private_cluster != null ? var.enable_private_cluster : try(local.gcp.enable_private_cluster, true)

  # Secondary ranges (null triggers auto-calculation in module)
  secondary_ranges = var.secondary_ranges != null ? var.secondary_ranges : try(local.gcp.secondary_ranges, null)

  # Master configuration
  master_ipv4_cidr           = var.master_ipv4_cidr != "" ? var.master_ipv4_cidr : try(local.gcp.master_ipv4_cidr, "172.16.0.0/28")
  master_authorized_networks = var.master_authorized_networks != null ? var.master_authorized_networks : try(local.gcp.master_authorized_networks, [])

  tags_merged = merge(local.tags, var.tags)
}

# Provider
provider "google" {
  project = local.gcp.project_id
  region  = local.gcp.region
}

# Network Module
module "network" {
  source = "../../../modules/foundation/infra/gcp/network"

  vpc_name               = local.vpc_name
  project_id             = local.gcp.project_id
  region                 = local.gcp.region
  subnet_cidr            = local.subnet_cidr
  cluster_name           = local.cluster_name
  enable_private_cluster = local.enable_private_cluster

  # Secondary ranges for pods and services
  secondary_ranges = local.secondary_ranges

  # Master network configuration
  master_ipv4_cidr           = local.master_ipv4_cidr
  master_authorized_networks = local.master_authorized_networks

  tags = local.tags_merged
}
