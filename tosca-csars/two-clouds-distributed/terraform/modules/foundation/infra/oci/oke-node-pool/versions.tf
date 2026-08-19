# Copyright (c) 2024
# OKE Node Pool Module

terraform {
  required_version = "~> 1.9"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 8.21.0"
    }
  }
}