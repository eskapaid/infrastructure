variable "environment" {
  description = "Working environment name, eg. develop or prod"
}

variable "region" {
  default     = "ap-southeast-1"
  description = "The AWS region in which resources are created. Used by EFS Provisioner"
}

variable "efs_id" {
  default     = "fs-changeme"
  description = "Used by AWS EFS Provisioner"
}

variable "cluster_name" {
  default     = "eks_cluster"
  description = "EKS Cluster Name"
}

variable "oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
}
