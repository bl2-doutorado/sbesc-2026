# Copyright (c) 2024
# OCI networking outputs

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.this.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = var.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet OCIDs"
  value       = [oci_core_subnet.load_balancer_subnet.id]
}

output "private_subnet_ids" {
  description = "List of private subnet OCIDs"
  value       = [oci_core_subnet.k8s_nodes_subnet.id]
}

# Named outputs for OKE cluster and node pool purposes
output "control_plane_subnet_id" {
  description = "Subnet OCID for OKE control plane (with Service Gateway access)"
  value       = oci_core_subnet.control_plane_subnet.id
}

output "service_lb_subnet_id" {
  description = "Public subnet OCID for OKE load balancers"
  value       = oci_core_subnet.load_balancer_subnet.id
}

output "nodes_subnet_id" {
  description = "Private subnet OCID for OKE worker nodes"
  value       = oci_core_subnet.k8s_nodes_subnet.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway"
  value       = oci_core_nat_gateway.this.id
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.this.id
}

output "nat_gateway_ip" {
  description = "IP address of the NAT Gateway"
  value       = oci_core_nat_gateway.this.nat_ip
}