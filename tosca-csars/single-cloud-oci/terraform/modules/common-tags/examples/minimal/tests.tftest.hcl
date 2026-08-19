# Tests for common-tags module
# Run with: cd examples/minimal && terraform test

run "test_aws_tags_format" {
  command = plan

  assert {
    condition     = length(module.tags.aws_tags) > 0
    error_message = "AWS tags should not be empty"
  }

  assert {
    condition     = can([for t in module.tags.aws_tags : t if t.Key == "ManagedBy"])
    error_message = "AWS tags should include ManagedBy"
  }

  assert {
    condition     = can([for t in module.tags.aws_tags : t if t.Key == "Environment"])
    error_message = "AWS tags should include Environment"
  }

  assert {
    condition     = can([for t in module.tags.aws_tags : t if t.Key == "Project"])
    error_message = "AWS tags should include Project"
  }
}

run "test_gcp_labels_format" {
  command = plan

  assert {
    condition     = module.tags.gcp_labels["managedby"] == "Terraform"
    error_message = "GCP labels should have managedby = Terraform"
  }

  assert {
    condition     = module.tags.gcp_labels["environment"] == "prod"
    error_message = "GCP labels should have environment = prod"
  }
}

run "test_oci_tags_format" {
  command = plan

  assert {
    condition     = module.tags.oci_freeform_tags["ManagedBy"] == "Terraform"
    error_message = "OCI tags should have ManagedBy = Terraform"
  }

  assert {
    condition     = module.tags.oci_freeform_tags["Environment"] == "prod"
    error_message = "OCI tags should have Environment = prod"
  }
}

run "test_aws_tags_count" {
  command = plan

  assert {
    condition     = length(module.tags.aws_tags) >= 3
    error_message = "AWS tags should have at least 3 tags (ManagedBy, Environment, Project)"
  }
}

run "test_gcp_labels_case" {
  command = plan

  assert {
    condition     = can(module.tags.gcp_labels["project"])
    error_message = "GCP labels should have project key (lowercase)"
  }
}

run "test_aws_managedby_value" {
  command = plan

  assert {
    condition     = can([for t in module.tags.aws_tags : t if t.Key == "ManagedBy" && t.Value == "Terraform"])
    error_message = "AWS tags should have ManagedBy = Terraform"
  }
}

run "test_aws_environment_value" {
  command = plan

  assert {
    condition     = can([for t in module.tags.aws_tags : t if t.Key == "Environment" && t.Value == "prod"])
    error_message = "AWS tags should have Environment = prod"
  }
}

run "test_oci_project_value" {
  command = plan

  assert {
    condition     = module.tags.oci_freeform_tags["Project"] == "test-project"
    error_message = "OCI tags should have Project = test-project"
  }
}