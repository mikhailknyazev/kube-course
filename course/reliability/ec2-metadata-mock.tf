locals {
  ec2_metadata_mock_name = "ec2-metadata-mock"
}

# https://github.com/aws/amazon-ec2-metadata-mock/tree/main/helm/amazon-ec2-metadata-mock
# Amazon EC2 Metadata Mock (AEMM) Helm chart for Kubernetes.
resource "helm_release" "ec2_metadata_mock" {
  name       = "ec2-metadata-mock"
  chart      = "https://github.com/aws/amazon-ec2-metadata-mock/releases/download/v1.9.0/amazon-ec2-metadata-mock-1.9.0.tgz"
  namespace  = "kube-system"
  values = [templatefile(
  "${path.module}/helm/values/ec2-metadata-mock.yaml",
  {
    name_override = local.ec2_metadata_mock_name
    system_ec2_logical_role_name = local.system_ec2_logical_role_name
  }
  )]
}
