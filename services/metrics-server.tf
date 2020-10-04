resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://storage.googleapis.com/kubernetes-charts"
  version    = "2.11.1"
  namespace  = kubernetes_namespace.monitor.metadata.0.name

  values = [
    templatefile("${path.module}/values/metrics-server.yaml", {
      # any template vars go here
    })
  ]
}