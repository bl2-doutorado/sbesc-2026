# Copyright (c) 2024
# OKE Node Pool Module outputs

output "node_pool_id" {
  description = "OCID of the node pool"
  value       = oci_containerengine_node_pool.this.id
}

output "node_count" {
  description = "Number of nodes in the pool"
  value       = oci_containerengine_node_pool.this.node_config_details[0].size
}

output "node_shape" {
  description = "Shape of the nodes"
  value       = oci_containerengine_node_pool.this.node_shape
}

output "kubernetes_version" {
  description = "Kubernetes version of the nodes"
  value       = oci_containerengine_node_pool.this.kubernetes_version
}

output "availability_domain" {
  description = "Availability domain of the nodes"
  value       = var.availability_domain
}

output "node_labels" {
  description = "Kubernetes labels applied to nodes"
  value       = var.node_labels
}

output "node_taints" {
  description = "Kubernetes taints applied to nodes"
  value       = var.node_taints
}