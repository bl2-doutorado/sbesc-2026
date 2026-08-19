# Copyright (c) 2024
# GCP Network Module outputs

output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.this.name
}

output "vpc_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.this.id
}

output "subnet_name" {
  description = "Name of the private subnet"
  value       = google_compute_subnetwork.private.name
}

output "subnet_id" {
  description = "Self-link of the private subnet"
  value       = google_compute_subnetwork.private.self_link
}

output "subnet_cidr" {
  description = "CIDR range of the private subnet"
  value       = google_compute_subnetwork.private.ip_cidr_range
}

output "secondary_ip_ranges" {
  description = "Secondary IP ranges of the subnet"
  value       = google_compute_subnetwork.private.secondary_ip_range
}
