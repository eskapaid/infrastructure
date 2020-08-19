resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://storage.googleapis.com/kubernetes-charts"
  namespace  = kubernetes_namespace.monitor.metadata.0.name
  version    = "2.11.1"

  values = [
    templatefile("${path.module}/chart-values/metrics-server.yaml", {
      # any template vars go here
    })
  ]
}