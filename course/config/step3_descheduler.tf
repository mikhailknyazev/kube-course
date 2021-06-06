
// Note: The "descheduler" has been disabled to give more room to pods of other demos in UI

// See: https://github.com/kubernetes-sigs/descheduler/tree/master/charts/descheduler
//resource "helm_release" "descheduler" {
//  name       = "descheduler"
//  chart      = "descheduler"
//  repository = "https://kubernetes-sigs.github.io/descheduler"
//  version    = "0.20.0"
//  namespace  = "kube-system"
//  values = [templatefile("${path.module}/helm/values/descheduler.yaml",
//  {
//    threshold_priority_class_name = "privileged"
//    workload_logical_role_name    = local.workload_logical_role_name
//  })]
//}
