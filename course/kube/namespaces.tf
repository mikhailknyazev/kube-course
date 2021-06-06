
locals {

  // Note: we want Terraform to ensure the order of resources creation...
  apps_namespace = kubernetes_namespace.apps.metadata[0].name

}

resource "kubernetes_namespace" "apps" {
  metadata {
    name = "apps"
  }
}

resource "kubernetes_role" "pod_reader" {

  metadata {
    name = "pod-reader"
    namespace  = local.apps_namespace
  }

  rule {
    api_groups     = [""]
    resources      = ["pods"]
    verbs          = ["get", "list", "watch"]
  }

}

resource "kubernetes_role_binding" "pod_reader_from_litmus_namespace" {
  metadata {
    name = "pod-reader-from-litmus-namespace"
    namespace  = local.apps_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.pod_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "litmus"
  }
}
