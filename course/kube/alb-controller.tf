locals {
  alb_controller_name = "alb-controller"
}

// https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  // See: https://aws.github.io/eks-charts/index.yaml
  repository = "https://aws.github.io/eks-charts"
  // See: https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
  version    = "1.2.3"
  namespace  = "kube-system"
  values = [templatefile(
  "${path.module}/helm/values/aws-alb-controller.yaml",
    {
      cluster_name = local.cluster_name
      name_override = local.alb_controller_name
      alb_controller_role_arn = module.iam_assumable_aws_alb_controller_role.iam_role_arn
    }
  )]

  depends_on = [module.kube]
}

module "iam_assumable_aws_alb_controller_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.2.0"
  create_role                   = true
  role_name                     = "aws-alb-controller-role-${local.cluster_name}"
  provider_url                  = module.kube.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:${local.alb_controller_name}"]
}

resource "aws_iam_role_policy" "inline_aws_alb_controller_policy" {
  name   = "alb_controller"
  policy = file("templates/alb-controller-policy.json")
  role = module.iam_assumable_aws_alb_controller_role.iam_role_name
}
