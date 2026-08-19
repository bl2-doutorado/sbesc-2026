# Tests for foundation module
# Run with: cd modules/foundation/examples/minimal && terraform test

# Note: These tests validate variable inputs only
# Full integration tests require cloud credentials

# Test that cloud variable validates correctly
run "test_invalid_cloud" {
  command = plan

  variables {
    cloud = "azure"
  }

  expect_failures = [
    var.cloud,
  ]
}

# Test that environment validates correctly
run "test_invalid_environment" {
  command = plan

  variables {
    environment = "production" # Should be prod, not production
  }

  expect_failures = [
    var.environment,
  ]
}

# Test that VPC CIDR validates correctly
run "test_invalid_vpc_cidr" {
  command = plan

  variables {
    vpc_cidr = "invalid-cidr"
  }

  expect_failures = [
    var.vpc_cidr,
  ]
}

# Test that project cannot be empty
run "test_empty_project" {
  command = plan

  variables {
    project = ""
  }

  expect_failures = [
    var.project,
  ]
}