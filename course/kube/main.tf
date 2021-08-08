
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.78.0"
  name                 = local.vpc_name
  cidr                 = "10.0.0.0/16"
  azs                  = [local.primary_az, local.secondary_az]
  public_subnets       = [local.primary_subnet, local.secondary_subnet]
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

module "kube" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.1.0"
  cluster_version = "1.21"
  cluster_name    = local.cluster_name
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true
  kubeconfig_output_path = "./config"
  kubeconfig_file_permission = "0644"

  worker_groups_launch_template = [
    {
      name                 = "system-ec2"
      subnets              = [local.primary_subnet_id, local.secondary_subnet_id]
      instance_type        = local.regular_instance_type

      asg_desired_capacity = 2
      asg_min_size = 2
      asg_max_size = 5

      // Cost Savings
//      asg_desired_capacity = 0
//      asg_min_size = 0
//      asg_max_size = 0

      public_ip            = true
      root_volume_type     = "gp2"

      kubelet_extra_args = local.workload_regular_ec2_kubelet_extra_args
      tags = local.common_instance_tags
    },
    {
      name                 = "tools"
      subnets              = [local.primary_subnet_id, local.secondary_subnet_id]
      instance_type        = local.regular_instance_type

      asg_desired_capacity = 1
      asg_min_size = 1
      asg_max_size = 1

      // Cost Savings
//      asg_desired_capacity = 0
//      asg_min_size = 0
//      asg_max_size = 0

      public_ip            = true
      root_volume_type     = "gp2"

      kubelet_extra_args = local.tools_regular_ec2_kubelet_extra_args

      tags = local.common_instance_tags
    }
  ]

}

