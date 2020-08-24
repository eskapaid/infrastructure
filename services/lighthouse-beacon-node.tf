data "aws_ssm_parameter" "alchemy_url" {
  name = "/staging/lighthouse/alchemy"
}

resource "helm_release" "lighthouse_beacon_node" {
  name      = "lighthouse-beacon-node"
  chart     = "${path.module}/charts/lighthouse/beacon-node"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/lighthouse-beacon-node.yaml", {
      environment = var.environment
      alchemy_url = data.aws_ssm_parameter.alchemy_url.value
    })
  ]
}