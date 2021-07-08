
locals {

  litmus_name = "litmus"

  // Note: we want Terraform to ensure the order of resources creation...
  litmus_namespace = kubernetes_namespace.litmus.metadata[0].name

}

resource "kubernetes_namespace" "litmus" {
  metadata {
    name = "litmus"
  }
}

// https://artifacthub.io/packages/helm/litmuschaos/litmus
resource "helm_release" "litmus" {
  name       = local.litmus_name
  namespace  = local.litmus_namespace

  chart      = "litmus"
  // Note: https://litmuschaos.github.io/litmus-helm/index.yaml
  repository = "https://litmuschaos.github.io/litmus-helm"
  version    = "1.15.0"

  values = [templatefile(
  "${path.module}/helm/values/litmus.yaml",
  {
    name_override = local.litmus_name
    tools_logical_role_name = local.tools_logical_role_name
    cluster_name = local.cluster_name
  }
  )]

  provisioner "local-exec" {
    when    = destroy
    command = "/course/reliability/clean-tests.sh"
  }

}

resource "helm_release" "kube_course_litmus_experiments" {
  name       = "kube-course-litmus-experiments"
  namespace  = local.litmus_namespace
  chart      = "${path.module}/helm/charts/kube-course-litmus-experiments"

  provisioner "local-exec" {
    command = "/course/reliability/init-secret-for-aws-experiments.sh"
  }

  depends_on = [helm_release.litmus]
}
