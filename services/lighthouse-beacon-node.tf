data "aws_ssm_parameter" "lighthouse_eth1endpoint" {
  name = "/staging/lighthouse/eth1endpoint"
}

resource "helm_release" "lighthouse_beacon_node" {
  name      = "lighthouse-beacon-node"
  chart     = "${path.module}/charts/lighthouse/beacon-node"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/lighthouse-beacon-node.yaml", {
      environment  = var.environment
      eth1endpoint = data.aws_ssm_parameter.lighthouse_eth1endpoint.value
    })
  ]
}