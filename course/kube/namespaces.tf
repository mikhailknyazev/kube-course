resource "kubernetes_namespace" "apps" {
  metadata {
    name = "apps"
  }
}
