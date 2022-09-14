resource "helm_release" "efs_provisioner" {
  name       = "efs-provisioner"
  chart      = "efs-provisioner"
  repository = "https://charts.helm.sh/stable"
  version    = "0.13.0"
  namespace  = "default"

  values = [
    templatefile("${path.module}/values/efs-provisioner.yaml", {
      environment = var.environment
      region      = var.region
      efs_id      = var.efs_id
    })
  ]
}