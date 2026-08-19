# Copyright (c) 2024
# GKE Node Pool Module - Creates managed node pool for GKE cluster

resource "google_container_node_pool" "this" {
  name       = var.pool_name
  cluster    = var.cluster_name
  location   = var.region
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    # Only set service_account if provided
    service_account = var.node_service_account_email != "" ? var.node_service_account_email : null

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = var.labels

    dynamic "taint" {
      for_each = var.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = ["gke-node", "${var.cluster_name}-node"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}
