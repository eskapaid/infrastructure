resource "random_id" "grafana_password" {
  byte_length = 8
}

resource "aws_ssm_parameter" "grafana_password" {
  name  = "/${var.environment}/grafana/password"
  type  = "SecureString"
  value = random_id.grafana_password.hex
}

# Grafana certificate. Can't use cert-manager cert with ALB Controller atm
data "aws_route53_zone" "current" {
  name = "${var.environment}.${var.domain}."
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = "grafana.${var.environment}.${var.domain}"
  subject_alternative_names = [
    "grafana.${var.environment}.${var.domain}",
  ]
  zone_id              = data.aws_route53_zone.current.id
  create_certificate   = true
  validate_certificate = true
  wait_for_validation  = true
}

resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  namespace  = kubernetes_namespace.monitor.metadata.0.name

  values = [
    templatefile("${path.module}/values/prometheus-stack.yaml", {
      environment             = var.environment
      domain                  = var.domain
      grafana_admin_password  = random_id.grafana_password.hex
      grafana_certificate_arn = module.acm.this_acm_certificate_arn
    })
  ]
}
