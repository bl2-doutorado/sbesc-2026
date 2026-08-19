output "vpc_name" {
  description = "Name of the VPC"
  value       = module.network.vpc_name
}

output "subnet_id" {
  description = "Subnet self-link"
  value       = module.network.subnet_id
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = module.network.subnet_name
}
