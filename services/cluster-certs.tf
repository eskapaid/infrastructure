resource "helm_release" "cluster_certs" {
  name      = "cluster-certs"
  chart     = "${path.module}/charts/cluster-certs"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/cluster-certs.yaml", {
      region      = var.region
      environment = var.environment
    })
  ]

  depends_on = [helm_release.cert_manager]
}