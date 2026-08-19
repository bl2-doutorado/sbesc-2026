# Copyright (c) 2024
# GKE Cluster Module - Creates managed Kubernetes cluster (control plane)

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.region

  # Disable deletion protection for development clusters
  deletion_protection = false

  # Zones where nodes will be created (empty = all zones in region)
  node_locations = var.node_locations

  # We use a separate node pool, so remove the default one
  remove_default_node_pool = true
  initial_node_count       = 1

  min_master_version = var.kubernetes_version

  # VPC-native networking
  network    = var.vpc_name
  subnetwork = var.subnet_ids[0]

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = var.private_cluster
    enable_private_endpoint = var.private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # IP allocation policy for VPC-native networking
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Master authorized networks
  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks != [] ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # Addons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = true
    }
  }

  # Datapath V2 (eBPF) - replaces Calico
  datapath_provider = "ADVANCED_DATAPATH"

  # Monitoring - disabled to avoid Alertmanager/Prometheus errors
  # Can be re-enabled later with managedPrometheus
  monitoring_config {
    enable_components = []
  }

  # Workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Maintenance window (daily 2am-6am UTC)
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  resource_labels = var.tags

  lifecycle {
    ignore_changes = [
      remove_default_node_pool,
      initial_node_count,
      node_locations,
    ]
  }

  # GKE cluster creation can take 5-10 minutes
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# Data source to get current user identity
data "google_client_openid_userinfo" "current" {}

# Data source to get Google client config for Kubernetes provider
data "google_client_config" "default" {}

# Kubernetes provider configuration for GKE
provider "kubernetes" {
  host                   = "https://${google_container_cluster.this.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.this.master_auth[0].cluster_ca_certificate)
}

# Kubernetes RBAC - Grant cluster-admin to the Terraform executor
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
    name = data.google_client_openid_userinfo.current.email
  }

  depends_on = [google_container_cluster.this]
}
