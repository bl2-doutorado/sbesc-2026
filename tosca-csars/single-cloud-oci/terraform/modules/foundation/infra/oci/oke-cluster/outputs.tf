# Copyright (c) 2024
# OKE Cluster Module outputs

output "cluster_id" {
  description = "OCID of the Kubernetes cluster"
  value       = oci_containerengine_cluster.this.id
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint URL"
  value       = try(oci_containerengine_cluster.this.endpoints[0], "pending")
}

output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = oci_containerengine_cluster.this.name
}

output "kubernetes_version" {
  description = "Kubernetes version of the cluster"
  value       = oci_containerengine_cluster.this.kubernetes_version
}

output "kubeconfig_command" {
  description = "OCI CLI command to retrieve kubeconfig"
  value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.this.id} --file $HOME/.kube/config --region ${var.region}"
}

output "vcn_id" {
  description = "VCN OCID where the cluster is deployed"
  value       = var.vcn_id
}

output "control_plane_subnet_id" {
  description = "Control plane subnet OCID"
  value       = var.control_plane_subnet_id
}

output "is_private_endpoint" {
  description = "Whether the cluster uses a private endpoint"
  value       = var.endpoint_is_private
}

output "region" {
  description = "OCI region where the cluster is deployed"
  value       = var.region
}
