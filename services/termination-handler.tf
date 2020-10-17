resource "helm_release" "termination_handler" {
  name       = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts"
  # version    = "0.9.1"
  namespace = "kube-system"

  values = [
    templatefile("${path.module}/values/termination-handler.yaml", {
      environment  = var.environment
      region       = var.region
      cluster_name = var.cluster_name
    })
  ]
}
