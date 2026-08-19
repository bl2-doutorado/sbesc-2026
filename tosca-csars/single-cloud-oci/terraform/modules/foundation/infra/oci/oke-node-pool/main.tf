# Copyright (c) 2024
# OKE Node Pool Module - Creates managed node pool for OKE cluster

locals {
  # Use provided image ID or default
  image_id = var.node_image_id != "" ? var.node_image_id : "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaacbcrwfck3m52pysb6dz7igpenqpiyxn4dlj6vbv3nvyoqqt7wdnq"

  # Use provided kubernetes version or default
  kubernetes_version = var.kubernetes_version != "" ? var.kubernetes_version : "v1.33.0"
}

resource "oci_containerengine_node_pool" "this" {
  compartment_id     = var.compartment_ocid
  cluster_id         = var.cluster_id
  name               = var.pool_name
  kubernetes_version = local.kubernetes_version
  node_shape         = var.node_shape
  freeform_tags      = merge(var.freeform_tags, { ManagedBy = "Terraform" })

  node_config_details {
    size = var.node_count

    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = var.subnet_ids[0]
    }

    node_pool_pod_network_option_details {
      cni_type       = "OCI_VCN_IP_NATIVE"
      pod_subnet_ids = var.subnet_ids
    }
  }

  node_eviction_node_pool_settings {
    #Optional
    eviction_grace_duration              = 60
    is_force_action_after_grace_duration = true
    is_force_delete_after_grace_duration = true
  }

  node_shape_config {
    memory_in_gbs = var.memory_in_gb
    ocpus         = var.ocpus
  }

  # Node source configuration
  # When source_type is "OKE", image_id is not required (uses cluster's default Oracle Linux)
  # When source_type is "IMAGE", image_id must be provided
  node_source_details {
    source_type = var.source_type
    image_id    = var.source_type == "IMAGE" ? local.image_id : null
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "40m"
  }
}
