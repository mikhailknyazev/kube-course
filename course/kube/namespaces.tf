
locals {

  // Note: we want Terraform to ensure the order of resources creation...
  apps_namespace = kubernetes_namespace.apps.metadata[0].name

}

resource "kubernetes_namespace" "apps" {
  metadata {
    name = "apps"
    # Ensure that health of ALB-linked Ingress-es / Pods in the namespaces
    # get wired to corresponding ALB Target Group's health by the ALB Controller chart
    labels = {
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
    }
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

resource "kubernetes_service_account" "helm_test" {
  metadata {
    name = "helm-test"
    namespace = local.apps_namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_role" "ingress_reader" {

  metadata {
    name = "ingress-reader"
    namespace  = local.apps_namespace
  }

  rule {
    api_groups     = ["networking.k8s.io"]
    resources      = ["ingresses"]
    verbs          = ["get", "list", "watch"]
  }

}

resource "kubernetes_role_binding" "ingress_reader_from_helm_test" {
  metadata {
    name = "ingress-reader-from-helm-test"
    namespace  = local.apps_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ingress_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.helm_test.metadata[0].name
    namespace = local.apps_namespace
  }
}
