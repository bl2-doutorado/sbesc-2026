output "vcn_id" {
  description = "ID of the VCN"
  value       = module.network.vcn_id
}

output "private_subnet_ids" {
  description = "List of private subnet OCIDs"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet OCIDs"
  value       = module.network.public_subnet_ids
}

# Named outputs for OKE cluster and node pool purposes
output "control_plane_subnet_id" {
  description = "Public subnet OCID for OKE control plane"
  value       = module.network.control_plane_subnet_id
}

output "service_lb_subnet_id" {
  description = "Public subnet OCID for OKE load balancers"
  value       = module.network.service_lb_subnet_id
}

output "nodes_subnet_id" {
  description = "Private subnet OCID for OKE worker nodes"
  value       = module.network.nodes_subnet_id
}
