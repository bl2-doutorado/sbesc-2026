# Copyright (c) 2024
# OCI Network - VCN and Subnets
# Reads config from live/envs/{env_name}.yaml, variables can override

terraform {
  required_version = "~> 1.9"

  required_providers {
    oci = {
      source = "oracle/oci"
      # version = ">= 8.21.0"
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

  # Apply overrides or use YAML values
  compartment_ocid          = var.compartment_ocid != "" ? var.compartment_ocid : local.oci.compartment_ocid
  vpc_cidr                  = var.vpc_cidr != "" ? var.vpc_cidr : try(local.oci.vpc_cidr, "10.0.0.0/16")
  availability_domain_count = var.availability_domain_count != null ? var.availability_domain_count : try(local.oci.availability_domain_count, 3)
}

# Provider
provider "oci" {
  region = local.oci.region

}

# Network Module
module "network" {
  source = "../../../modules/foundation/infra/oci/network"

  vpc_cidr                  = local.vpc_cidr
  environment               = var.env_name
  project                   = local.tags.Project
  region                    = local.oci.region
  compartment_ocid          = local.compartment_ocid
  availability_domain_count = local.availability_domain_count
}
