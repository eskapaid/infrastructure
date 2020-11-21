resource "helm_release" "cluster_certs" {
  name      = "cluster-certs"
  chart     = "${path.module}/charts/cluster-certs"
  namespace = "default"

  values = [
    templatefile("${path.module}/values/cluster-certs.yaml", {
      region      = var.region
      environment = var.environment
    })
  ]

  depends_on = [helm_release.cert_manager]
}