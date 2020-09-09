resource "helm_release" "lighthouse_validator" {
  name      = "lighthouse-validator"
  chart     = "${path.module}/charts/lighthouse/validator"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/lighthouse-validator.yaml", {
      environment = var.environment
    })
  ]
}