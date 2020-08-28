resource "helm_release" "prysm_validator" {
  name      = "prysm-validator"
  chart     = "${path.module}/charts/prysm/validator"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/prysm-validator.yaml", {
      environment = var.environment
    })
  ]
}