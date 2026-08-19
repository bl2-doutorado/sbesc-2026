# Copyright (c) 2024
# GKE Cluster Module outputs

output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the GKE cluster API server"
  value       = google_container_cluster.this.endpoint
}

output "cluster_version" {
  description = "Kubernetes version of the GKE cluster"
  value       = google_container_cluster.this.master_version
}

output "cluster_ca_certificate" {
  description = "Base64 encoded CA certificate for the cluster"
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "project_id" {
  description = "GCP project ID where the cluster is deployed"
  value       = var.project_id
}

output "region" {
  description = "GCP region where the cluster is deployed"
  value       = var.region
}

output "kubeconfig_command" {
  description = "gcloud command to get cluster credentials"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.this.name} --region ${var.region} --project ${var.project_id}"
}
