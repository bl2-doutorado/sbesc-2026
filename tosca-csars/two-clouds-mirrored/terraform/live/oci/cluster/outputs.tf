output "cluster_id" {
  description = "OCID of the OKE cluster"
  value       = module.oke_cluster.cluster_id
}

output "cluster_name" {
  description = "Name of the cluster"
  value       = module.oke_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.oke_cluster.cluster_endpoint
}

output "region" {
  description = "OCI region where the cluster is deployed"
  value       = module.oke_cluster.region
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig"
  value       = module.oke_cluster.kubeconfig_command
}
