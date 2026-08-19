# Minimal example for foundation module validation
# Used as test fixture

variable "cloud" {
  type    = string
  default = "aws"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "test-project"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cloud_specific_config" {
  type    = map(any)
  default = {}
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "availability_count" {
  type    = number
  default = null
}

module "foundation" {
  source = "../../"

  cloud                 = var.cloud
  environment           = var.environment
  project               = var.project
  vpc_cidr              = var.vpc_cidr
  cloud_specific_config = var.cloud_specific_config
  region                = var.region
  availability_count    = var.availability_count
}