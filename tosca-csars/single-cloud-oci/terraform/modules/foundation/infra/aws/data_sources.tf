# Copyright (c) 2024
# AWS data sources for dynamic AZ discovery

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Use specified count or all available AZs (up to the count)
  target_azs = var.availability_zone_count != null ? slice(data.aws_availability_zones.available.names, 0, var.availability_zone_count) : data.aws_availability_zones.available.names

  az_count = length(local.target_azs)
}