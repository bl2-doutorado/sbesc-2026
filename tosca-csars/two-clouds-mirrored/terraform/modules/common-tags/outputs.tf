# Copyright (c) 2024
# Outputs for provider-specific tag formats

output "aws_tags" {
  description = "Tags formatted for AWS resources (list of {Key, Value} objects)"
  value       = local.aws_tags_list
}

output "gcp_labels" {
  description = "Labels formatted for GCP resources (map of strings, lowercase keys)"
  value       = local.gcp_labels_map
}

output "oci_freeform_tags" {
  description = "Tags formatted for OCI resources (map of strings, preserved key casing)"
  value       = local.oci_freeform_tags_map
}