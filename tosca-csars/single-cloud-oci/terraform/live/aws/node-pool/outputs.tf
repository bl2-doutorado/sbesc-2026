output "node_group_name" {
  description = "Name of the node group"
  value       = module.eks_node_group.node_group_name
}

output "node_count" {
  description = "Number of nodes in the group"
  value       = module.eks_node_group.node_count
}

output "node_names" {
  description = "List of node names (EC2 instance IDs)"
  value       = module.eks_node_group.node_names
}
