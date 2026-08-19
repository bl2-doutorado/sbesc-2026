output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.gke_cluster.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded CA certificate for the cluster"
  value       = module.gke_cluster.cluster_ca_certificate
  sensitive   = true
}

output "project_id" {
  description = "GCP project ID where the cluster is deployed"
  value       = module.gke_cluster.project_id
}

output "region" {
  description = "GCP region where the cluster is deployed"
  value       = module.gke_cluster.region
}

output "kubeconfig_command" {
  description = "Command to get cluster credentials"
  value       = module.gke_cluster.kubeconfig_command
}
