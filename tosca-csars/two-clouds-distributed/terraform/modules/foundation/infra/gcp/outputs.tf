# Copyright (c) 2024
# GCP networking outputs

output "vpc_id" {
  description = "Self link of the VPC network"
  value       = google_compute_network.this.id
}

output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.this.name
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = var.vpc_cidr
}

output "private_subnet_ids" {
  description = "List of private subnetwork self links"
  value       = values(google_compute_subnetwork.private)[*].id
}

output "public_subnet_ids" {
  description = "List of public subnetwork self links"
  value       = values(google_compute_subnetwork.public)[*].id
}

output "nat_gateway_ip" {
  description = "IP address of the Cloud NAT"
  value       = try(one(google_compute_router_nat.this.nat_ips), null)
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.this.name
}

output "zones" {
  description = "List of zones used"
  value       = local.target_zones
}