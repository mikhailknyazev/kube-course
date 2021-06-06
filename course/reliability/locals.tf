locals {
  config_context               = "eks_kube"
  cluster_name                 = data.terraform_remote_state.kube.outputs.cluster_name
  tools_logical_role_name      = data.terraform_remote_state.kube.outputs.tools_logical_role_name
}
