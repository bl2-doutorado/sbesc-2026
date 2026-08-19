# Foundation Module

A unified Terraform module that provisions core networking infrastructure for AWS, GCP, and OCI from a single interface.

## Overview

This module abstracts cloud-specific networking details, providing a consistent interface for consumers regardless of which cloud is deployed. It provisions VPC/VCN, subnets (public/private), NAT gateways, and route tables.

## Usage

```hcl
module "foundation" {
  source = "./modules/foundation"

  cloud       = "aws"  # aws, gcp, or oci
  environment = "prod"
  project     = "k8s-platform"
  vpc_cidr    = "10.0.0.0/16"

  cloud_specific_config = {
    # For GCP
    project_id = "my-gcp-project"

    # For OCI
    compartment_ocid = "ocid1.compartment.oc1...."
  }
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `cloud` | Target cloud provider | `string` | Yes | - |
| `environment` | Environment name (dev, staging, prod) | `string` | Yes | - |
| `project` | Project name for resource naming | `string` | Yes | - |
| `vpc_cidr` | CIDR block for VPC/VCN | `string` | No | `10.0.0.0/16` |
| `cloud_specific_config` | Provider-specific configuration | `map(any)` | No | `{}` |
| `region` | Cloud region | `string` | No | Provider default |
| `availability_count` | Number of AZs to use | `number` | No | All available |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC/VCN |
| `vpc_cidr` | CIDR block of the VPC/VCN |
| `private_subnet_ids` | List of private subnet IDs |
| `public_subnet_ids` | List of public subnet IDs |
| `nat_gateway_ip` | IP address of the NAT gateway |
| `internet_gateway_id` | ID of the Internet Gateway |
| `availability_zones` | List of availability zones used |
| `cloud` | The cloud provider being used |
| `environment` | The environment name |
| `project` | The project name |

## Cloud-Specific Configuration

### AWS
No additional configuration required. Uses AWS default region.

### GCP
```hcl
cloud_specific_config = {
  project_id = "my-gcp-project"
}
```

### OCI
```hcl
cloud_specific_config = {
  compartment_ocid = "ocid1.compartment.oc1...."
}
```

## Requirements

- Terraform >= 1.9
- AWS provider ~> 5.0
- Google provider ~> 5.0
- OCI provider ~> 8.21.0