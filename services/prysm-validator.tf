data "aws_ssm_parameter" "prysm_keystore" {
  name = "/${var.environment}/prysm/keystore"
}

data "aws_ssm_parameter" "prysm_password" {
  name = "/${var.environment}/prysm/password"
}

data "aws_ssm_parameter" "prysm_keymanager" {
  name = "/${var.environment}/prysm/keymanager"
}

resource "kubernetes_secret" "prysm_keystore" {
  metadata {
    name      = "prysm-keystore"
    namespace = kubernetes_namespace.services.metadata.0.name
  }

  data = {
    "all-accounts.keystore.json" = data.aws_ssm_parameter.prysm_keystore.value
  }
}

resource "kubernetes_secret" "prysm_password" {
  metadata {
    name      = "prysm-password"
    namespace = kubernetes_namespace.services.metadata.0.name
  }

  data = {
    "password.txt" = data.aws_ssm_parameter.prysm_password.value
  }
}

resource "kubernetes_secret" "prysm_keymanager" {
  metadata {
    name      = "prysm-keymanager"
    namespace = kubernetes_namespace.services.metadata.0.name
  }

  data = {
    "keymanageropts.json" = data.aws_ssm_parameter.prysm_keymanager.value
  }
}

resource "helm_release" "prysm_validator" {
  name      = "prysm-validator"
  chart     = "${path.module}/charts/prysm/validator"
  namespace = kubernetes_namespace.services.metadata.0.name

  values = [
    templatefile("${path.module}/values/prysm-validator.yaml", {
      environment = var.environment
    })
  ]
}