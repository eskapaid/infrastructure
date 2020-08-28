data "aws_ssm_parameter" "prysm_eth1endpoint" {
  name = "/staging/prysm/eth1endpoint"
}

resource "helm_release" "prysm_beacon" {
  name      = "prysm-beacon"
  chart     = "${path.module}/charts/prysm/beacon"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/prysm-beacon.yaml", {
      environment  = var.environment
      eth1endpoint = data.aws_ssm_parameter.prysm_eth1endpoint.value
    })
  ]
}