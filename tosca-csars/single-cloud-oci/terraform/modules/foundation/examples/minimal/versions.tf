# Copyright (c) 2024
# Foundation module version constraints with mock configuration

terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 8.21.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 8.21.0"
    }
    oci = {
      source  = "oracle/oci"
      version = ">= 8.21.0"
    }
  }
}

# Mock providers for testing (valid credentials not required)
provider "aws" {
  region = "us-east-1"
}

provider "google" {
  project = "test-project"
  region  = "us-east1"
}

provider "oci" {
  region = "us-ashburn-1"
}
