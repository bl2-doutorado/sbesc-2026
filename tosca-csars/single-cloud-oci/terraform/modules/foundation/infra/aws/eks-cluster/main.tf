# Copyright (c) 2024
# EKS Cluster Module - Creates managed Kubernetes cluster (control plane)

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = var.security_group_ids != "" ? [var.security_group_ids] : []
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = merge(var.tags, {
    ManagedBy = "Terraform"
  })

  lifecycle {
    create_before_destroy = true
  }

  # EKS cluster creation can take 10-15 minutes
  timeouts {
    create = "30m"
    update = "20m"
    delete = "20m"
  }
}

# Data source to get current AWS caller identity
data "aws_caller_identity" "current" {}

# AWS EKS Access Entry - Grant cluster access to the Terraform executor
resource "aws_eks_access_entry" "terraform_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_caller_identity.current.arn
}

# AWS EKS Access Policy Association - Grant cluster-admin permissions
resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_caller_identity.current.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.terraform_admin]
}
