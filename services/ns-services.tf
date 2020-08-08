locals {
  services_namespace = "services"
}

resource "kubernetes_namespace" "services" {
  metadata {
    annotations = {
      name = local.services_namespace
    }

    name = local.services_namespace
  }
}