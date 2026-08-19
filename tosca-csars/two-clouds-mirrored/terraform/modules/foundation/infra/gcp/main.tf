# Copyright (c) 2024
# GCP networking infrastructure

locals {
  project_id = var.project_id
}

# VPC Network
resource "google_compute_network" "this" {
  name                    = "${var.project}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460

  routing_mode = "REGIONAL"

  lifecycle {
    create_before_destroy = true
  }
}

# Public Subnets (one per zone)
resource "google_compute_subnetwork" "public" {
  for_each = toset(local.target_zones)

  name          = "${var.project}-public-${each.key}"
  network       = google_compute_network.this.id
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 8, index(local.target_zones, each.key))
  region        = var.region

  private_ip_google_access = false

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Private Subnets (one per zone)
resource "google_compute_subnetwork" "private" {
  for_each = toset(local.target_zones)

  name          = "${var.project}-private-${each.key}"
  network       = google_compute_network.this.id
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 8, local.zone_count + index(local.target_zones, each.key))
  region        = var.region

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Cloud Router
resource "google_compute_router" "this" {
  name    = "${var.project}-router"
  network = google_compute_network.this.id
  region  = var.region

  bgp {
    asn = 64514
  }
}

# Cloud NAT
resource "google_compute_router_nat" "this" {
  name   = "${var.project}-nat"
  router = google_compute_router.this.name
  region = var.region

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  min_ports_per_vm = 32
  max_ports_per_vm = 65536

  enable_endpoint_independent_mapping = true

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall Rule: Allow internal traffic
resource "google_compute_firewall" "allow_internal" {
  name     = "${var.project}-allow-internal"
  network  = google_compute_network.this.name
  priority = 65534

  direction     = "INGRESS"
  source_ranges = ["10.0.0.0/8"]

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
}

# Firewall Rule: Allow SSH from internal (restricted)
resource "google_compute_firewall" "allow_ssh" {
  name     = "${var.project}-allow-ssh"
  network  = google_compute_network.this.name
  priority = 65534

  direction     = "INGRESS"
  source_ranges = ["10.0.0.0/16"]

  target_tags = ["allow-ssh"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Firewall Rule: Allow health checks
resource "google_compute_firewall" "allow_health_checks" {
  name     = "${var.project}-allow-health-checks"
  network  = google_compute_network.this.name
  priority = 65534

  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  target_tags = ["allow-health-checks"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}