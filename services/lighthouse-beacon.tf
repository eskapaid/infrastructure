data "aws_ssm_parameter" "lighthouse_eth1endpoint" {
  name = "/staging/lighthouse/eth1endpoint"
}

resource "helm_release" "lighthouse_beacon" {
  name      = "lighthouse-beacon"
  chart     = "${path.module}/charts/lighthouse/beacon"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/lighthouse-beacon.yaml", {
      environment  = var.environment
      eth1endpoint = data.aws_ssm_parameter.lighthouse_eth1endpoint.value
    })
  ]
}