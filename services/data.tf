data "aws_eks_cluster" "current" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}