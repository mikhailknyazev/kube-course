locals {
  config_context               = "eks_kube"
  cluster_name                 = data.terraform_remote_state.kube.outputs.cluster_name
  workload_logical_role_name   = data.terraform_remote_state.kube.outputs.workload_logical_role_name
}
