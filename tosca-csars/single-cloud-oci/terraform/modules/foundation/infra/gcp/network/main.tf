# Copyright (c) 2024
# GCP Network Module - VPC, Subnets, Firewall for GKE

terraform {
  required_version = "~> 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.42.0"
    }
  }
}

# ============================================
# Local values with auto-calculation
# ============================================
locals {
  # Auto-calculate secondary ranges if not provided
  secondary_ranges = var.secondary_ranges != null ? var.secondary_ranges : {
    pods     = cidrsubnet(var.subnet_cidr, 4, 2)
    services = cidrsubnet(var.subnet_cidr, 2, 3)
  }
}

# VPC Network
resource "google_compute_network" "this" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Private Subnet for GKE nodes
resource "google_compute_subnetwork" "private" {
  name                     = "${var.vpc_name}-private-${var.region}"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  # Secondary range for GKE pods
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = local.secondary_ranges.pods
  }

  # Secondary range for GKE services
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = local.secondary_ranges.services
  }


#  dynamic "secondary_ip_range" {
#    for_each = var.secondary_ip_ranges
#    content {
#      range_name    = secondary_ip_range.value.name
#      ip_cidr_range = secondary_ip_range.value.cidr
#    }
#  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  depends_on = [google_compute_network.this]
}

# Firewall: Allow internal traffic
resource "google_compute_firewall" "internal" {
  name    = "${var.vpc_name}-allow-internal"
  project = var.project_id
  network = google_compute_network.this.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.subnet_cidr,
    "10.0.0.0/8"
  ]

  depends_on = [google_compute_network.this]
}

# Firewall: Allow GKE master to node communication
resource "google_compute_firewall" "gke_master" {
  count   = var.enable_private_cluster ? 1 : 0
  name    = "${var.vpc_name}-gke-master-${var.cluster_name}"
  project = var.project_id
  network = google_compute_network.this.id

  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }

  source_ranges = [var.master_ipv4_cidr]
  target_tags   = ["gke-${var.cluster_name}"]

  depends_on = [google_compute_network.this]
}

# Firewall: Allow health checks
resource "google_compute_firewall" "health_checks" {
  name    = "${var.vpc_name}-allow-health-checks"
  project = var.project_id
  network = google_compute_network.this.id

  allow {
    protocol = "tcp"
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  depends_on = [google_compute_network.this]
}
