output "pool_name" {
  description = "Name of the node pool"
  value       = module.gke_node_pool.pool_name
}

output "node_count" {
  description = "Number of nodes in the pool"
  value       = module.gke_node_pool.node_count
}

output "node_names" {
  description = "List of node names"
  value       = module.gke_node_pool.node_names
}
