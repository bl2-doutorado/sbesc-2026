# Copyright (c) 2024
# EKS Node Group Module outputs

output "node_group_name" {
  description = "Name of the node group"
  value       = aws_eks_node_group.this.node_group_name
}

output "node_count" {
  description = "Number of nodes in the group"
  value       = var.node_count
}

output "node_role_arn" {
  description = "ARN of the IAM role for the nodes"
  value       = aws_eks_node_group.this.node_role_arn
}

output "node_names" {
  description = "List of node names (EC2 instance IDs) for workload mapping"
  value       = try(aws_eks_node_group.this.resources[*].id, [])
}

output "instance_type" {
  description = "EC2 instance type of the nodes"
  value       = var.instance_type
}

output "labels" {
  description = "Kubernetes labels applied to the nodes"
  value       = var.labels
}
