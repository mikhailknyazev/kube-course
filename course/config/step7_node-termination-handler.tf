locals {
  node_termination_handler_name = "node-termination-handler"
}

# https://github.com/aws/aws-node-termination-handler
# Gracefully handle EC2 instance shutdown within Kubernetes.
resource "helm_release" "aws_node_termination_handler" {
  name       = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  // See: https://aws.github.io/eks-charts/index.yaml
  repository = "https://aws.github.io/eks-charts"
  version    = "0.15.0"
  namespace  = "kube-system"
  values = [templatefile(
  "${path.module}/helm/values/node-termination-handler.yaml",
    {
      cluster_name  = local.cluster_name,
      name_override = local.node_termination_handler_name
      workload_logical_role_name = local.workload_logical_role_name
      webhookURL = var.node_termination_handler_webhook_url
    }
  )]
}
