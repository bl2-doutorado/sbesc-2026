# Kubernetes Templates for Optimizer

This directory contains YAML template files used by the bin packing optimizer to generate final Terraform configurations.

## Available Templates

| Template | Cloud | Description |
|----------|-------|-------------|
| `aws-k8s.yaml.tmpl` | AWS | EKS cluster and node groups |
| `gcp-k8s.yaml.tmpl` | GCP | GKE cluster and node pools |
| `oci-k8s.yaml.tmpl` | OCI | OKE cluster and node pools |

## Template Format

Templates use `<<< SECTION >>>` markers that the optimizer replaces with actual values.

### Common Markers

| Marker | Description | Example Value |
|--------|-------------|---------------|
| `<<< REGION >>>` | Cloud provider region | `us-west-2` |
| `<<< CLUSTER_NAME >>>` | Kubernetes cluster name | `k8s-aws-prod` |
| `<<< K8S_VERSION >>>` | Kubernetes version | `1.31` |
| `<<< NODE_POOLS >>>` | Node pool definitions | See below |
| `<<< TAGS >>>` | Resource tags/labels | See below |

### AWS-Specific Markers

| Marker | Description | Example Value |
|--------|-------------|---------------|
| `<<< VPC_ID >>>` | VPC ID | `vpc-0abc123` |
| `<<< SUBNET_IDS >>>` | List of subnet IDs | `- subnet-0aaa` |
| `<<< CLUSTER_ROLE_ARN >>>` | IAM role ARN | `arn:aws:iam::...` |
| `<<< NODE_ROLE_ARN >>>` | IAM role ARN | `arn:aws:iam::...` |
| `<<< ENDPOINT_PRIVATE >>>` | Private endpoint | `true` |
| `<<< ENDPOINT_PUBLIC >>>` | Public endpoint | `false` |

### GCP-Specific Markers

| Marker | Description | Example Value |
|--------|-------------|---------------|
| `<<< PROJECT_ID >>>` | GCP project ID | `my-project` |
| `<<< VPC_NAME >>>` | VPC name | `k8s-platform-vpc` |
| `<<< SUBNET_IDS >>>` | Subnet self links | `- https://...` |
| `<<< PRIVATE_CLUSTER >>>` | Private cluster | `true` |

### OCI-Specific Markers

| Marker | Description | Example Value |
|--------|-------------|---------------|
| `<<< ENVIRONMENT >>>` | Environment name | `prod` |
| `<<< PROJECT >>>` | Project name | `k8s-platform` |
| `<<< COMPARTMENT_OCID >>>` | OCI compartment OCID | `ocid1.compartment...` |
| `<<< VCN_ID >>>` | VCN OCID | `ocid1.vcn...` |
| `<<< PUBLIC_SUBNET_ID >>>` | Public subnet OCID | `ocid1.subnet...` |
| `<<< PRIVATE_SUBNET_IDS >>>` | Private subnet OCIDs | `- ocid1.subnet...` |
| `<<< ENDPOINT_IS_PRIVATE >>>` | Private endpoint | `true` |

## Node Pools Format

The `<<< NODE_POOLS >>>` marker should be replaced with YAML list entries:

```yaml
  # AWS example
  - name: c5-2xlarge-pool
    instance_type: c5.2xlarge
    count: 4
    labels:
      workload: compute
      cloud: aws

  # GCP example
  - name: e2-standard-8-pool
    machine_type: e2-standard-8
    count: 1
    labels:
      workload: compute
      cloud: gcp

  # OCI example
  - name: general
    instance_type: VM.Standard.A1.Flex
    count: 1
    memory_gb: 16
    ocpus: 4
    availability_domain: JvzU:SA-SAOPAULO-1-AD-1
    source_type: IMAGE
    image_id: ocid1.image...
    labels:
      workload: general
```

## Tags Format

The `<<< TAGS >>>` marker should be replaced with YAML key-value pairs:

```yaml
  # AWS/OCI style
  CostCenter: platform
  Owner: devops
  ManagedBy: Terraform

  # GCP style (lowercase with hyphens)
  cost-center: platform
  owner: devops
  managed-by: terraform
```

## Usage

1. Optimizer reads template file
2. Replaces markers with values from JSON allocations and system context
3. Writes final YAML to `terraform/config/` directory
4. Terraform reads the YAML via wrapper module

## Validation

After substitution, validate the generated YAML:

```bash
# Check YAML syntax
python3 -c "import yaml; yaml.safe_load(open('config/aws-k8s.yaml'))"

# Run terraform validate
cd live/aws-prod/eks && terraform validate
cd live/gcp-prod/gke && terraform validate
cd live/oci-k8s-prod && terraform validate
```
