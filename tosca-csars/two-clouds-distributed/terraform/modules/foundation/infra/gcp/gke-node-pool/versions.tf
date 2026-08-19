# Copyright (c) 2024
# GKE Node Pool Module versions

terraform {
  required_version = "~> 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.42.0"
    }
  }
}
