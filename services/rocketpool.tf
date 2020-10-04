data "aws_ssm_parameter" "rocketpool_infura" {
  name = "/staging/rocketpool/infura-id"
}

resource "helm_release" "rocketpool" {
  name      = "rocketpool"
  chart     = "${path.module}/charts/rocketpool"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/rocketpool.yaml", {
      environment = var.environment
      infura_id   = data.aws_ssm_parameter.rocketpool_infura.value
    })
  ]
}