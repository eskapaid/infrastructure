resource "helm_release" "efs_provisioner" {
  name      = "efs-provisioner"
  chart     = "stable/efs-provisioner"
  namespace = "default"

  values = [
    templatefile("${path.module}/values/efs-provisioner.yaml", {
      environment = var.environment
      region      = var.region
      efs_id      = var.efs_id
    })
  ]
}