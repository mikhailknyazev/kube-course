
# See https://artifacthub.io/packages/helm/metrics-server/metrics-server
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://olemarkus.github.io/metrics-server"
  version    = "2.11.2"
  namespace  = "kube-system"
  values     = [file("${path.module}/helm/values/metrics-server.yaml")]
}
