# Copyright (c) 2024
# GCP data sources for dynamic zone discovery

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

locals {
  # Use specified count or all available zones (up to the count)
  target_zones = var.zone_count != null ? slice(data.google_compute_zones.available.names, 0, var.zone_count) : data.google_compute_zones.available.names

  zone_count = length(local.target_zones)
}