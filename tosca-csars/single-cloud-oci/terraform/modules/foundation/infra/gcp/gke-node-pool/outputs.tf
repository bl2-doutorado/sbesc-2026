# Copyright (c) 2024
# GKE Node Pool Module outputs

output "pool_name" {
  description = "Name of the node pool"
  value       = google_container_node_pool.this.name
}

output "node_count" {
  description = "Number of nodes in the pool"
  value       = var.node_count
}

output "node_names" {
  description = "List of node names for workload mapping"
  value       = []
  # Note: GKE node names are only available after cluster creation
  # Use: gcloud container nodes list --cluster <name> --region <region>
}

output "machine_type" {
  description = "Machine type of the nodes"
  value       = var.machine_type
}

output "labels" {
  description = "Kubernetes labels applied to the nodes"
  value       = var.labels
}
