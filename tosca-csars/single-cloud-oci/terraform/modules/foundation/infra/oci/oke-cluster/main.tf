# Copyright (c) 2024
# OKE Cluster Module - Creates managed Kubernetes cluster (control plane)

# terraform {
#   required_version = "~> 1.9"

#   required_providers {
#     oci = {
#       source  = "oracle/oci"
#       # version = ">= 8.21.0"
#       version = ">= 8.21.0"
#     }
#   }
# }

resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_ocid
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vcn_id             = var.vcn_id

  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }

  endpoint_config {
    is_public_ip_enabled = !var.endpoint_is_private
    subnet_id            = var.control_plane_subnet_id
  }

  options {
    service_lb_subnet_ids = var.service_lb_subnet_id != "" ? [var.service_lb_subnet_id] : []

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }

    add_ons {
      is_kubernetes_dashboard_enabled = var.kubernetes_dashboard_enabled
      is_tiller_enabled               = var.tiller_is_enabled
    }
  }

  freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
  })

  lifecycle {
    create_before_destroy = true
  }

  # OKE cluster creation can take 10-20 minutes
  timeouts {
    create = "30m"
    update = "20m"
    delete = "10m"
  }
}

# Kubernetes provider configuration for OCI OKE
# Uses exec plugin to generate token via OCI CLI
provider "kubernetes" {
  host = oci_containerengine_cluster.this.endpoints[0].kubernetes

  # Note: OCI OKE does not expose CA certificate directly
  # Using exec plugin for authentication
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", oci_containerengine_cluster.this.id, "--file", "-"]
  }
}

# Kubernetes RBAC - Grant cluster-admin to the Terraform executor
# Note: This requires the Kubernetes provider to be configured with proper authentication
resource "kubernetes_cluster_role_binding_v1" "terraform_admin" {
  metadata {
    name = "terraform-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind = "User"
    name = "terraform"
  }

  depends_on = [oci_containerengine_cluster.this]
}
