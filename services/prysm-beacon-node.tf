data "aws_ssm_parameter" "prysm_eth1endpoint" {
  name = "/staging/prysm/eth1endpoint"
}

resource "helm_release" "beacon_node" {
  name      = "prysm-beacon-node"
  chart     = "${path.module}/charts/prysm/beacon-node"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/prysm-beacon-node.yaml", {
      environment  = var.environment
      eth1endpoint = data.aws_ssm_parameter.prysm_eth1endpoint.value
    })
  ]
}