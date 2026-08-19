# Copyright (c) 2024
# EKS Node Group Module versions

terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 8.21.0"
    }
  }
}
