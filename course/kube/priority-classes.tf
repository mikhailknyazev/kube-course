
resource "kubernetes_priority_class" "privileged" {
  metadata {
    name = "privileged"
  }
  global_default = true
  value = 500000000 // 500 M
}

resource "kubernetes_priority_class" "regular" {
  metadata {
    name = "regular"
  }
  value = 200000000 // 200 M
}

resource "kubernetes_priority_class" "overprovisioning" {
  metadata {
    name = "overprovisioning"
  }
  value = -1
}
