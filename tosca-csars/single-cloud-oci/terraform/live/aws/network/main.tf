# Copyright (c) 2024
# AWS Network - VPC and Subnets
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
  tags   = local.config.tags

  # Apply overrides or use YAML values
  vpc_cidr           = var.vpc_cidr != "" ? var.vpc_cidr : try(local.aws.vpc_cidr, "10.0.0.0/16")
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : try(local.aws.availability_zones, ["${local.aws.region}a", "${local.aws.region}b", "${local.aws.region}c"])
  tags_merged        = merge(local.tags, var.tags)
}

# Provider
provider "aws" {
  region = local.aws.region
}

# Network Module
module "network" {
  source = "../../../modules/foundation/infra/aws/network"

  vpc_cidr           = local.vpc_cidr
  environment        = var.env_name
  project            = local.tags_merged.Project
  region             = local.aws.region
  availability_zones = local.availability_zones

  tags = local.tags_merged
}
