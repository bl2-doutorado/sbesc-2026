# Copyright (c) 2024
# OCI-specific networking variables

variable "vpc_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name for resource naming"
  type        = string

  validation {
    condition     = length(var.project) > 0
    error_message = "Project name cannot be empty."
  }
}

variable "region" {
  description = "OCI region for resources"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "OCI compartment OCID"
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.oc[0-9]+.*", var.compartment_ocid))
    error_message = "Must be a valid OCI compartment OCID (starts with ocid1.compartment.oc...)."
  }
}

variable "availability_domain_count" {
  description = "Number of availability domains to use (null = all available)"
  type        = number
  default     = null
  nullable    = true

  validation {
    condition     = var.availability_domain_count == null || (var.availability_domain_count >= 1 && var.availability_domain_count <= 3)
    error_message = "Availability domain count must be between 1 and 3."
  }
}
