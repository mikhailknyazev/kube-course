locals {

  cluster_name = "kube"
  vpc_name     = "kube-vpc"

  tools_logical_role_name = "tools"
  workload_logical_role_name = "workload"

  sorted_azs   = sort(data.aws_availability_zones.available_zones.names)
  primary_az = local.sorted_azs[0]
  secondary_az = local.sorted_azs[1]

  primary_subnet = "10.0.1.0/24"
  secondary_subnet = "10.0.2.0/24"
  primary_subnet_id = module.vpc.public_subnets[0]
  secondary_subnet_id = module.vpc.public_subnets[1]

  common_instance_tags = [
    {
      key = "owner"
      propagate_at_launch = "true"
      value = "kube-course"
    }
  ]

  workload_regular_ec2_kubelet_extra_args  = "--node-labels=node.kubernetes.io/lifecycle=normal,role=${local.workload_logical_role_name}"

  tools_regular_ec2_kubelet_extra_args  = "--node-labels=node.kubernetes.io/lifecycle=normal,role=${local.tools_logical_role_name} --register-with-taints=${local.tools_logical_role_name}=true:NoSchedule"

  regular_instance_type = "t3.medium"

}
