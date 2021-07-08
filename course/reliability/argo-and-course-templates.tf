
locals {

  argo_name = "argo"
  argo_chaos_sa_name = "argo-chaos"

}

// https://github.com/argoproj/argo-helm/tree/master/charts/argo-workflows
// https://artifacthub.io/packages/helm/argo/argo
resource "helm_release" "argo" {
  name       = local.argo_name
  namespace  = local.litmus_namespace

  chart      = "argo-workflows"
  // Note: https://argoproj.github.io/argo-helm/index.yaml
  repository = "https://argoproj.github.io/argo-helm"
  version    = "0.2.6"

  values = [templatefile(
  "${path.module}/helm/values/argo.yaml",
  {
    name_override = local.argo_name
    tools_logical_role_name = local.tools_logical_role_name
    workflow_service_account_name = local.argo_chaos_sa_name
    cluster_name = local.cluster_name
  }
  )]

  depends_on = [kubernetes_service_account.argo_chaos, module.iam_assumable_argo_chaos_role]

  provisioner "local-exec" {
    when    = destroy
    command = "/course/reliability/clean-tests.sh"
  }

}

resource "kubernetes_ingress" "argo_server_ingress" {

  wait_for_load_balancer = true

  metadata {

    name = "argo-server"
    namespace  = local.litmus_namespace

    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"

      # Note: we are using the "tools" ALB Group here, it is shared with Jenkins (under "/jenkins/*")
      #       Hence, the ALB instance is shared for all the "tools" (NOT apps/workloads).
      # See also: https://kubernetes-sigs.github.io/aws-load-balancer-controller/guide/ingress/annotations/#group.order
      "alb.ingress.kubernetes.io/group.name" = "${local.cluster_name}-tools-alb-group"
      "alb.ingress.kubernetes.io/group.order" = "500"

      # This setting is related to:
      # - https://github.com/argoproj/argo-workflows/issues/4804
      # - https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#connection-idle-timeout
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=600"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "30"
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" = "5"
      "alb.ingress.kubernetes.io/healthy-threshold-count" = "2"
      "alb.ingress.kubernetes.io/unhealthy-threshold-count" = "3"
    }
    labels = {
      "ingress.class" = "alb"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = "argo-server"
            service_port = 2746
          }
        }
      }
    }
  }

  depends_on = [helm_release.argo]

}

module "iam_assumable_argo_chaos_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.2.0"
  create_role                   = true
  role_name                     = "argo-chaos-role-${local.cluster_name}"
  provider_url                  = data.terraform_remote_state.kube.outputs.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.litmus_namespace}:${local.argo_chaos_sa_name}"]
}

resource "aws_iam_role_policy" "inline_argo_chaos_policy" {
  name   = "argo-chaos"
  policy = templatefile("templates/argo-policy.json", { cluster_name = local.cluster_name })
  role = module.iam_assumable_argo_chaos_role.iam_role_name
}

resource "kubernetes_cluster_role_binding" "argo_chaos" {
  metadata {
    name = local.argo_chaos_sa_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.argo_chaos_sa_name
    namespace = local.litmus_namespace
  }
}

resource "kubernetes_service_account" "argo_chaos" {
  metadata {
    name = local.argo_chaos_sa_name
    namespace = local.litmus_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_argo_chaos_role.iam_role_arn
    }
  }
  automount_service_account_token = true
}

# Note: faster Terraform apply for development purposes:
#   terraform apply -target "helm_release.kube_course_templates"
resource "helm_release" "kube_course_templates" {
  name       = "kube-course-templates"
  namespace  = local.litmus_namespace
  chart      = "${path.module}/helm/charts/kube-course-templates"

  // Note: this construct below ensures that the Helm Chart gets updated
  //       on any change to the Argo Workflow Templates files.
  // See also: https://github.com/hashicorp/terraform-provider-helm/issues/372
  set {
    name = "templatesChecksum"
    value = md5(join("", [
      for f in fileset("${path.module}/helm/charts/kube-course-templates/steps", "*"):
        filemd5("${path.module}/helm/charts/kube-course-templates/steps/${f}")
    ]))
  }

  depends_on = [helm_release.argo]
}
