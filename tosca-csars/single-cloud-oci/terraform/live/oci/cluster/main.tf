# Copyright (c) 2024
# OCI OKE Cluster - creates control plane only
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
  config  = yamldecode(file("${path.module}/../../envs/${var.env_name}.yaml"))
  oci     = local.config.oci
  cluster = local.config.cluster
  tags    = local.config.tags

  # Apply overrides or use YAML values
  # Priority: var > YAML network outputs > YAML static values
  cluster_name            = var.cluster_name != "" ? var.cluster_name : local.cluster.name
  compartment_ocid        = var.compartment_ocid != "" ? var.compartment_ocid : local.oci.compartment_ocid
  vcn_id                  = var.vcn_id != "" ? var.vcn_id : try(local.oci.vcn_id, "")
  kubernetes_version      = var.kubernetes_version != "" ? var.kubernetes_version : local.cluster.kubernetes_version
  control_plane_subnet_id = var.control_plane_subnet_id != "" ? var.control_plane_subnet_id : try(local.oci.control_plane_subnet_id, try(local.oci.public_subnet_ids[0], ""))
  service_lb_subnet_id    = var.service_lb_subnet_id != "" ? var.service_lb_subnet_id : try(local.oci.service_lb_subnet_id, try(local.oci.public_subnet_ids[0], ""))
  endpoint_is_private     = var.endpoint_is_private != null ? var.endpoint_is_private : try(local.cluster.endpoint_is_private, true)
  tags_merged             = merge(local.tags, var.tags)
}

# Provider
provider "oci" {
  region = local.oci.region
}

# OKE Cluster Module
module "oke_cluster" {
  source = "../../../modules/foundation/infra/oci/oke-cluster"

  compartment_ocid        = local.compartment_ocid
  cluster_name            = local.cluster_name
  vcn_id                  = local.vcn_id
  kubernetes_version      = local.kubernetes_version
  control_plane_subnet_id = local.control_plane_subnet_id
  endpoint_is_private     = local.endpoint_is_private
  service_lb_subnet_id    = local.service_lb_subnet_id
  region                  = local.oci.region
}
