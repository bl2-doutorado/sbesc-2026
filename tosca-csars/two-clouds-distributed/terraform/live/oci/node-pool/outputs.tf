output "node_pool_id" {
  description = "OCID of the node pool"
  value       = module.oke_node_pool.node_pool_id
}

output "node_count" {
  description = "Number of nodes in the pool"
  value       = module.oke_node_pool.node_count
}
