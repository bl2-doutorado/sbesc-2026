# Copyright (c) 2024
# OCI networking infrastructure - Regional subnets only

locals {
  compartment_id            = var.compartment_ocid
  k8s_nodes_subnet_cidr     = cidrsubnet(var.vpc_cidr, 8, 10)
  control_plane_subnet_cidr = cidrsubnet(var.vpc_cidr, 12, 0)
  load_balancer_subnet_cidr = cidrsubnet(var.vpc_cidr, 8, 20)
}

# Note: Provider is inherited from parent module.

# Data source for OCI services (must be declared before resources that use it)
data "oci_core_services" "this" {}

# VCN (Virtual Cloud Network)
resource "oci_core_vcn" "this" {
  compartment_id = local.compartment_id
  cidr_blocks    = [var.vpc_cidr]
  display_name   = "oke-vcn-${var.project}-${var.environment}"
  dns_label      = substr("${var.environment}", 0, 15)
  # default_route_table_id = oci_core_route_table.public.id

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "this" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.this.id
  enabled        = true
  display_name   = "oke-igw-${var.project}-${var.environment}"

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# NAT Gateway
resource "oci_core_nat_gateway" "this" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "oke-ngw-${var.project}-${var.environment}"

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Service Gateway (for OCI services access from private subnets)
resource "oci_core_service_gateway" "this" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "oke-sgw-${var.project}-${var.environment}"

  services {
    service_id = data.oci_core_services.this.services[0].id
  }

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Route Table for Public Subnets (via Internet Gateway)
resource "oci_core_route_table" "public" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "oke-public-routetable-${var.project}-${var.environment}"
  # Internet access (includes OCI services)
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.this.id
  }

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "public"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route Table for Private Subnets (via NAT Gateway and Service Gateway)
resource "oci_core_route_table" "private" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "oke-private-routetable-${var.project}-${var.environment}"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.this.id
  }

  route_rules {
    destination       = data.oci_core_services.this.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
  }

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "private"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security List for Public Subnets
resource "oci_core_security_list" "load_balancer_security_list" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "oke-svclbseclist-${var.project}-${var.environment}"

  # egress_security_rules {
  #   destination = "0.0.0.0/0"
  #   protocol    = "all"
  # }

  # # HTTP
  # ingress_security_rules {
  #   source   = "0.0.0.0/0"
  #   protocol = "6"
  #   tcp_options {
  #     min = 80
  #     max = 80
  #   }
  # }

  # # HTTPS
  # ingress_security_rules {
  #   source   = "0.0.0.0/0"
  #   protocol = "6"
  #   tcp_options {
  #     min = 443
  #     max = 443
  #   }
  # }

  # # Kubernetes API (6443) - nodes to control plane
  # ingress_security_rules {
  #   source   = "10.0.0.0/16"
  #   protocol = "6"
  #   tcp_options {
  #     min = 6443
  #     max = 6443
  #   }
  # }

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security List for Private Subnets (Worker Nodes)
resource "oci_core_security_list" "k8s_nodes_security_list" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "oke-nodeseclist-${var.project}-${var.environment}"




  # Allow all traffic from VCN for pod-to-pod communication
  ingress_security_rules {
    source      = local.k8s_nodes_subnet_cidr
    protocol    = "all"
    description = "Allow all traffic from VCN for pod-to-pod communication"
  }

  ingress_security_rules {
    description = "Path discovery"
    source      = local.control_plane_subnet_cidr
    protocol    = "1"
    # type = "ICMP"

    icmp_options {
      #Required
      type = 3

      #Optional
      code = 4
    }
  }

  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    source      = local.control_plane_subnet_cidr
    protocol    = "6"

  }

  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    protocol    = "6"
    source      = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }

  }

  egress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination = local.k8s_nodes_subnet_cidr
    protocol    = "all"
  }

  egress_security_rules {
    description = "Access to Kubernetes API Endpoint"
    destination = local.control_plane_subnet_cidr
    protocol    = "6"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    description = "Kubernetes worker to control plane communication"
    destination = local.control_plane_subnet_cidr
    protocol    = "6"
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    description = "Kubernetes worker to control plane communication"
    destination = local.control_plane_subnet_cidr
    protocol    = "6"
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    description = "Path discovery"
    destination = local.control_plane_subnet_cidr
    protocol    = "1"
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = data.oci_core_services.this.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    description = "ICMP Access from Kubernetes Control Plane"
    destination = "0.0.0.0/0"
    protocol    = "1"
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    description = "Worker Nodes access to Internet"
    destination = "0.0.0.0/0"
    protocol    = "all"

  }

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# # Route Table for Control Plane (Service Gateway + NAT Gateway for internet)
# resource "oci_core_route_table" "control_plane" {
#   compartment_id = local.compartment_id
#   vcn_id         = oci_core_vcn.this.id
#   display_name   = "${var.project}-rt-control-plane"

#   # OCI services access via Service Gateway
#   route_rules {
#     destination       = data.oci_core_services.this.services[0].cidr_block
#     destination_type  = "SERVICE_CIDR_BLOCK"
#     network_entity_id = oci_core_service_gateway.this.id
#   }

#   # Internet access via NAT Gateway (for pulling images, etc.)
#   route_rules {
#     destination       = "0.0.0.0/0"
#     network_entity_id = oci_core_nat_gateway.this.id
#   }

#   freeform_tags = {
#     Environment = var.environment
#     Project     = var.project
#     ManagedBy   = "Terraform"
#     Type        = "control-plane"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# Security List for Control Plane
resource "oci_core_security_list" "control_plane" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "oke-k8sApiEndpoint-${var.project}-${var.environment}"

  # Egress: allow all outbound
  ingress_security_rules {
    source      = "0.0.0.0/0"
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    source      = local.k8s_nodes_subnet_cidr
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    source      = local.k8s_nodes_subnet_cidr
    description = "Kubernetes worker to control plane communication"
    protocol    = "6"
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    source      = local.k8s_nodes_subnet_cidr
    description = "Path discovery"
    protocol    = "1"
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    destination      = data.oci_core_services.this.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    protocol         = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    destination      = local.k8s_nodes_subnet_cidr
    destination_type = "CIDR_BLOCK"
    description      = "All traffic to worker nodes"
    protocol         = "6"
  }

  egress_security_rules {
    destination      = local.k8s_nodes_subnet_cidr
    destination_type = "CIDR_BLOCK"
    description      = "Path discovery"
    protocol         = "1"
    icmp_options {
      type = 3
      code = 4
    }
  }

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Subnet for Control Plane (with Service Gateway access)
resource "oci_core_subnet" "control_plane_subnet" {
  compartment_id             = local.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = local.control_plane_subnet_cidr
  display_name               = "oke-k8sApiEndpoint-subnet-${var.project}-${var.environment}-regional"
  dns_label                  = "controlsubnet"
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.control_plane.id]
  prohibit_public_ip_on_vnic = true # Control plane needs public IP for kubectl

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "control-plane"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Regional Public Subnet (for Load Balancers)
resource "oci_core_subnet" "load_balancer_subnet" {
  compartment_id             = local.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = local.load_balancer_subnet_cidr
  display_name               = "oke-svclb-subnet-${var.project}-${var.environment}-regional"
  dns_label                  = "loadsubnet"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.load_balancer_security_list.id]
  prohibit_public_ip_on_vnic = false

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "public-regional"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Regional Private Subnet (for OKE cluster nodes and other workloads)
resource "oci_core_subnet" "k8s_nodes_subnet" {
  compartment_id             = local.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = local.k8s_nodes_subnet_cidr
  display_name               = "oke-node-subnet-${var.project}-${var.environment}-regional"
  dns_label                  = "k8snodesubnet"
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.k8s_nodes_security_list.id]
  prohibit_public_ip_on_vnic = true

  freeform_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "private-regional"
  }

  lifecycle {
    create_before_destroy = true
  }
}
