# Copyright (c) 2024
# AWS-specific networking variables

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
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
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone_count" {
  description = "Number of availability zones to use (null = all available)"
  type        = number
  default     = null
  nullable    = true

  validation {
    condition     = var.availability_zone_count == null || (var.availability_zone_count >= 1 && var.availability_zone_count <= 3)
    error_message = "Availability zone count must be between 1 and 3."
  }
}
