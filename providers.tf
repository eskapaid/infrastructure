terraform {
  required_version = ">= 1"

  cloud {
    organization = "eskapaid"

    workspaces {
      name = "prod"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    external = {
      source = "hashicorp/external"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    local = {
      source = "hashicorp/local"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"

  #   assume_role {
  #     role_arn = var.tf_cloud_role # Set in Terraform Cloud Variables tab
  #   }
}

# Use template file and fill in the computed values
provider "template" {}

# Write a file to local disk
provider "local" {}

# Query external data sources eg. bash scripts
provider "external" {}

# allows the use of randomness within Terraform configurations
provider "random" {}

# For K8s deployment resources
# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   load_config_file       = false
# }

# Deploy Helm charts with Terraform
# provider "helm" {
#   kubernetes {
#     load_config_file       = false
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#   }
# }