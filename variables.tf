variable "tf_cloud_role" {
  type    = string
  default = ""
}

variable "region" {
  description = "The AWS region in which resources are created"
  default     = "ap-southeast-2"
}

variable "environment" {
  description = "AWS environment, eg. develop or prod"
  default     = "prod"
}

variable "cluster_version" {
  description = "Kubernetes version to run on EKS"
  default     = "1.17"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "private_subnets" {
  type    = list(any)
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "public_subnets" {
  type    = list(any)
  default = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
}

# Services module
# These are set in Terraform Cloud

variable "grafana_admin_password" {
  default = "changeme"
}