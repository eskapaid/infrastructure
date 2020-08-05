terraform {
  required_version = ">= 0.12"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "eskapaid"

    workspaces {
      prefix = "infrastructure-"
    }
  }
}

provider "aws" {
  version = "~> 2"
  region  = "ap-southeast-1"

  assume_role {
    role_arn = var.tf_cloud_role # Set in Terraform Cloud Variables tab
  }
}

# Use template file and fill in the computed values
provider "template" {
  version = "~> 2.1"
}

# Write a file to local disk
provider "local" {
  version = "~> 1.4"
}

# Query external data sources eg. bash scripts
provider "external" {
  version = "~> 1.2"
}

# For K8s deployment resources
provider "kubernetes" {
  version                = "~> 1.11"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

# Deploy Helm charts with Terraform
provider "helm" {
  version = "~> 1.0"

  kubernetes {
    load_config_file       = false
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}