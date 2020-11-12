resource "random_id" "grafana_password" {
  byte_length = 8
}

resource "aws_ssm_parameter" "grafana_password" {
  name  = "${var.environment}/grafana/password"
  type  = "SecureString"
  value = random_id.grafana_password.hex
}

resource "helm_release" "prometheus_stack" {
  name       = "prometheus-stack"
  chart      = "prometheus-community/kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  namespace  = kubernetes_namespace.monitor.metadata.0.name
  version    = "11.1.1"

  values = [
    templatefile("${path.module}/values/prometheus-stack.yaml", {
      environment            = var.environment
      grafana_admin_password = random_id.grafana_password.hex
    })
  ]
}
