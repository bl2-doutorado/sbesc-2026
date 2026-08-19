# Copyright (c) 2024
# EKS Node Group Module - Creates managed node group for EKS cluster

resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = [var.instance_type]
  capacity_type   = var.capacity_type

  scaling_config {
    desired_size = var.node_count
    max_size     = var.node_count
    min_size     = var.node_count
  }

  update_config {
    max_unavailable = 1
  }

  labels = var.labels

  dynamic "taint" {
    for_each = var.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(var.tags, {
    ManagedBy = "Terraform"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  # Node group creation can take 5-10 minutes
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}
