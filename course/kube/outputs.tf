output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

// Networking

output "primary_az" {
  value = local.primary_az
}

output "secondary_az" {
  value = local.secondary_az
}

// apse2-az1
output "primary_az_id" {
  value = data.aws_availability_zone.primary.zone_id
}

// apse2-az3
output "secondary_az_id" {
  value = data.aws_availability_zone.secondary.zone_id
}

output "primary_subnet_id" {
  value = local.primary_subnet_id
}

output "secondary_subnet_id" {
  value = local.secondary_subnet_id
}

// EKS

output "cluster_endpoint" {
  description = "Endpoint of EKS Control Plane"
  value = module.kube.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value = module.kube.cluster_id
}

output "cluster_oidc_issuer_url" {
  value = module.kube.cluster_oidc_issuer_url
}

output "tools_logical_role_name" {
  value = local.tools_logical_role_name
}
