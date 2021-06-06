
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.kube.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.kube.cluster_id
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

data "aws_availability_zone" "primary" {
  name = local.primary_az
}

data "aws_availability_zone" "secondary" {
  name = local.secondary_az
}
