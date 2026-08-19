# Copyright (c) 2024
# AWS networking infrastructure

# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project}-vpc"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project}-igw"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project}-nat-eip"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id

  tags = {
    Name        = "${var.project}-nat"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }
}

# Public Subnets (one per AZ)
resource "aws_subnet" "public" {
  for_each = toset(local.target_azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, index(local.target_azs, each.key))
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-public-${each.key}"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "public"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Private Subnets (one per AZ)
resource "aws_subnet" "private" {
  for_each = toset(local.target_azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, local.az_count + index(local.target_azs, each.key))
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project}-private-${each.key}"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "private"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.project}-rt-public"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "public"
  }
}

# Private Route Table (with NAT Gateway for outbound traffic)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name        = "${var.project}-rt-private"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Type        = "private"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}