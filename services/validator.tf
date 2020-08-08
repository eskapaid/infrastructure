resource "helm_release" "validator" {
  name      = "validator"
  chart     = "${path.module}/charts/prysm/validator"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/chart-values/validator.yaml", {
      environment = var.environment
    })
  ]
}