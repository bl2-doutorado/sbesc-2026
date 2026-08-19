# Minimal example - defines infrastructure under test
# Used as test fixture by tests.tftest.hcl

variable "environment" {
  type    = string
  default = "prod"
}

variable "project" {
  type    = string
  default = "test-project"
}

variable "cost_center" {
  type    = string
  default = ""
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

module "tags" {
  source = "../../"

  environment = var.environment
  project     = var.project
  cost_center = var.cost_center
  extra_tags  = var.extra_tags
}