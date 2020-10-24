data "aws_ssm_parameter" "slack_webhook" {
  name = "/${var.environment}/slack-webhook"
}

resource "helm_release" "termination_handler" {
  name       = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts"
  version    = "0.10.0"
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/values/termination-handler.yaml", {
      environment   = var.environment
      slack_webhook = data.aws_ssm_parameter.slack_webhook.value
      cluster_name  = var.cluster_name
    })
  ]
}
