locals {
  monitor_namespace = "monitor"
}

resource "kubernetes_namespace" "monitor" {
  metadata {
    annotations = {
      name = local.monitor_namespace
    }

    name = local.monitor_namespace
  }
}
