# Copyright (c) 2024
# GKE Cluster - creates control plane only
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
  config  = yamldecode(file("${path.module}/../../envs/${var.env_name}.yaml"))
  gcp     = local.config.gcp
  cluster = local.config.cluster
  tags    = local.config.tags

  # Apply overrides or use YAML values
  cluster_name       = var.cluster_name != "" ? var.cluster_name : local.cluster.name
  kubernetes_version = var.kubernetes_version != "" ? var.kubernetes_version : local.cluster.kubernetes_version
  subnet_id          = var.subnet_id != "" ? var.subnet_id : try(local.gcp.private_subnet_ids[0], "")
  vpc_name           = var.vpc_name != "" ? var.vpc_name : local.gcp.vpc_name
  private_cluster    = var.private_cluster != null ? var.private_cluster : try(local.cluster.private_cluster, true)
  private_endpoint   = var.private_endpoint != null ? var.private_endpoint : try(local.cluster.private_endpoint, false)

  # Master network configuration
  master_ipv4_cidr_block     = var.master_ipv4_cidr_block != "" ? var.master_ipv4_cidr_block : try(local.gcp.master_ipv4_cidr, "172.16.0.0/28")
  master_authorized_networks = var.master_authorized_networks != null ? var.master_authorized_networks : try(local.gcp.master_authorized_networks, [])

  # Node locations (empty = all zones in region)
  node_locations = var.node_locations != null ? var.node_locations : try(local.gcp.node_locations, [])

  tags_merged = merge(local.tags, var.tags)
}

# Provider
provider "google" {
  project = local.gcp.project_id
  region  = local.gcp.region
}

# GKE Cluster
module "gke_cluster" {
  source = "../../../modules/foundation/infra/gcp/gke-cluster"

  cluster_name       = local.cluster_name
  kubernetes_version = local.kubernetes_version
  region             = local.gcp.region
  project_id         = local.gcp.project_id
  vpc_name           = local.vpc_name
  subnet_ids         = [local.subnet_id]
  private_cluster    = local.private_cluster
  private_endpoint   = local.private_endpoint

  # Master network configuration
  master_ipv4_cidr_block     = local.master_ipv4_cidr_block
  master_authorized_networks = local.master_authorized_networks

  # Node locations
  node_locations = local.node_locations

  tags = local.tags_merged
}
