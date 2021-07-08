
locals {
  # This is used to name most k8s resources, including the service account name
  cluster_autoscaler_name = "cluster-autoscaler"
}

# https://github.com/kubernetes/autoscaler
# https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
# https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler/templates
# https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  chart      = "cluster-autoscaler"
  // See: https://kubernetes.github.io/autoscaler/index.yaml
  repository = "https://kubernetes.github.io/autoscaler"
  version    = "9.9.2"

  values = [templatefile(
    "${path.module}/helm/values/cluster-autoscaler.yaml",
    {
      region                       = var.region
      cluster_name                 = local.cluster_name
      name_override                = local.cluster_autoscaler_name
      system_ec2_logical_role_name = local.system_ec2_logical_role_name
      cluster_autoscaler_role_arn  = module.iam_assumable_cluster_autoscaler_role.iam_role_arn
    }
  )]

  depends_on = [aws_iam_role_policy.inline_cluster_autoscaler_policy]

}

module "iam_assumable_cluster_autoscaler_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.2.0"
  create_role                   = true
  role_name                     = "cluster-autoscaler-role-${local.cluster_name}"
  provider_url                  = data.terraform_remote_state.kube.outputs.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:${local.cluster_autoscaler_name}"]
}

resource "aws_iam_role_policy" "inline_cluster_autoscaler_policy" {
  name   = "cluster-autoscaler"
  policy = templatefile("templates/cluster-autoscaler-policy.json", { cluster_name = local.cluster_name })
  role = module.iam_assumable_cluster_autoscaler_role.iam_role_name
}
