
locals {
  jenkins_name = "jenkins"
  jenkins_agent_service_account_name = kubernetes_service_account.jenkins_agent.metadata[0].name

  // Note: we want Terraform to ensure the order of resources creation...
  jenkins_namespace = kubernetes_namespace.jenkins.metadata[0].name
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

# https://github.com/jenkinsci/helm-charts/tree/main/charts/jenkins
# https://artifacthub.io/packages/helm/jenkinsci/jenkins
# https://charts.jenkins.io/index.yaml
resource "helm_release" "jenkins" {
  name       = local.jenkins_name
  namespace  = local.jenkins_namespace

  chart      = "jenkins"
  // See: https://charts.jenkins.io/index.yaml
  repository = "https://charts.jenkins.io"
  version    = "3.5.9"

  values = [templatefile(
  "${path.module}/helm/values/jenkins.yaml",
  {
    name_override = local.jenkins_name
    namespace_override = local.jenkins_namespace
    tools_logical_role_name = local.tools_logical_role_name
    cluster_name = local.cluster_name
  }
  )]

  depends_on = [
    kubernetes_service_account.jenkins_agent
  ]
}

resource "kubernetes_cluster_role_binding" "jenkins-agent" {
  metadata {
    name = local.jenkins_agent_service_account_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.jenkins_agent_service_account_name
    namespace = local.jenkins_namespace
  }
}

resource "kubernetes_service_account" "jenkins_agent" {
  metadata {
    name = "jenkins-agent"
    namespace = local.jenkins_namespace
  }
  automount_service_account_token = true
}
