resource "helm_release" "beacon_node" {
  name      = "beacon-node"
  chart     = "${path.module}/charts/prysm/beacon"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/chart-values/beacon-node.yaml", {
      environment = var.environment
    })
  ]
}