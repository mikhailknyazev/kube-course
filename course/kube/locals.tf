locals {

  cluster_name = "kube"
  vpc_name     = "kube-vpc"

  tools_logical_role_name = "tools"
  system_ec2_logical_role_name = "system-ec2"
  workload_logical_role_name = "workload"

  sorted_azs   = sort(data.aws_availability_zones.available_zones.names)
  primary_az = local.sorted_azs[0]
  secondary_az = local.sorted_azs[1]

  primary_subnet = "10.0.1.0/24"
  secondary_subnet = "10.0.2.0/24"
  primary_subnet_id = module.vpc.public_subnets[0]
  secondary_subnet_id = module.vpc.public_subnets[1]

  workload_instance_tags = [
    {
      key = "k8s.io/cluster-autoscaler/enabled"
      propagate_at_launch = "false"
      value = "true"
    },
    {
      key = "k8s.io/cluster-autoscaler/${local.cluster_name}"
      propagate_at_launch = "false"
      value = "owned"
    },
    {
      key = "owner"
      propagate_at_launch = "true"
      value = "kube-course"
    }
  ]

  workload_regular_ec2_kubelet_extra_args  = "--node-labels=node.kubernetes.io/lifecycle=normal,role=${local.workload_logical_role_name} --register-with-taints=${local.system_ec2_logical_role_name}=true:NoExecute"

  workload_spot_ec2_kubelet_extra_args  = "--node-labels=node.kubernetes.io/lifecycle=spot,role=${local.workload_logical_role_name},spot-node-termination=regular "

  tools_regular_ec2_kubelet_extra_args  = "--node-labels=node.kubernetes.io/lifecycle=normal,role=${local.tools_logical_role_name} --register-with-taints=${local.tools_logical_role_name}=true:NoSchedule"

  // ec2-instance-selector --flexible --usage-class spot --base-instance-type "t3.medium" --availability-zones "apse2-az1"
  // Note: use output.primary_az_id and output.secondary_az_id
  regular_instance_type = "t3.medium"
  spot_instance_types = ["t3.medium", "t2.medium"]

}
