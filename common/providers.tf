provider "aws" {
  # To prevent automatic upgrades to new major versions
  # that may contain breaking changes
  version = "~> 2.0"

  # Adding alias to be consistent with staging environment, which is located in a different region
  region = "ap-southeast-1"

  # assume_role {
  #   role_arn = var.fountain_tf_role # Set in Terraform Cloud Variables tab
  # }
}

terraform {
  required_version = ">= 0.12"

  backend "remote" {
    organization = "eskapaid"

    workspaces {
      name = "infrastructure-common"
    }
  }
}