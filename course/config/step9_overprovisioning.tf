
# Overprovisioning Configuration
resource "helm_release" "overprovisioning" {
  name       = "overprovisioning"
  namespace  = "kube-system"
  chart      = "${path.module}/helm/charts/overprovisioning"
  values = [templatefile(
  "${path.module}/helm/values/overprovisioning.yaml",
  {
    overprovisioning_enabled = true
//    overprovisioning_enabled = false
    replicas = 1
    primaryAz = data.terraform_remote_state.kube.outputs.primary_az
    secondaryAz = data.terraform_remote_state.kube.outputs.secondary_az
    cpu = "1500m"
    memory = "300M"
  }
  )]
}
