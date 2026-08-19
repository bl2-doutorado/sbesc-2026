output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.eks_cluster.cluster_id
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks_cluster.cluster_arn
}

output "cluster_certificate_authority" {
  description = "Base64 encoded certificate data for the cluster"
  value       = module.eks_cluster.cluster_certificate_authority
  sensitive   = true
}

output "region" {
  description = "AWS region where the cluster is deployed"
  value       = module.eks_cluster.region
}

output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = module.eks_cluster.kubeconfig_command
}
