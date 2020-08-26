data "aws_ssm_parameter" "web3provider" {
  name = "/staging/prysm/web3provider"
}

resource "helm_release" "beacon_node" {
  name      = "prysm-beacon-node"
  chart     = "${path.module}/charts/prysm/beacon-node"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/prysm-beacon-node.yaml", {
      environment  = var.environment
      web3provider = data.aws_ssm_parameter.web3provider.value
    })
  ]
}