locals {
  config_context               = "eks_kube"
  cluster_name                 = data.terraform_remote_state.kube.outputs.cluster_name
  system_ec2_logical_role_name = data.terraform_remote_state.kube.outputs.system_ec2_logical_role_name
  tools_logical_role_name      = data.terraform_remote_state.kube.outputs.tools_logical_role_name
}
