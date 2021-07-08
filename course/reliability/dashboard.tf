
locals {
  kubernetes_dashboard_name = "dashboard"
}

resource "kubernetes_namespace" "dashboard" {
  metadata {
    name = "dashboard"
  }
}

// https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard
resource "helm_release" "kubernetes_dashboard" {
  name       = local.kubernetes_dashboard_name
  namespace  = kubernetes_namespace.dashboard.metadata[0].name

  chart      = "kubernetes-dashboard"
  // https://kubernetes.github.io/dashboard/index.yaml
  repository = "https://kubernetes.github.io/dashboard"
  version    = "4.3.1"

  values = [templatefile(
  "${path.module}/helm/values/dashboard.yaml",
  {
    name_override = local.kubernetes_dashboard_name
    tools_logical_role_name = local.tools_logical_role_name
    kubernetes_dashboard_sa_name = local.kubernetes_dashboard_name
    cluster_name = local.cluster_name
  }
  )]

}
