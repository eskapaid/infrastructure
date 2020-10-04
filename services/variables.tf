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