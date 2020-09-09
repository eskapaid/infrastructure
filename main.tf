# Deploy various services to K8s
module "services" {
  source      = "./services"
  environment = var.environment
  # cluster_name = module.eks.cluster_id
  # oidc_issuer_url        = module.eks.cluster_oidc_issuer_url
  # grafana_admin_password = var.grafana_admin_password
  # papertrail_uri         = var.papertrail_uri
}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.44.0"
  name                 = "vpc-${var.environment}"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # These tags are required for EKS to know which subnets to use
  tags = {
    "kubernetes.io/cluster/eks-${var.environment}" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/eks-${var.environment}" = "shared"
    "kubernetes.io/role/elb"                       = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/eks-${var.environment}" = "shared"
    "kubernetes.io/role/internal-elb"              = "1"
  }
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "12.2.0"
  cluster_name                    = "eks-${var.environment}"
  cluster_version                 = var.cluster_version
  subnets                         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  vpc_id                          = module.vpc.vpc_id
  worker_ami_name_filter          = "amazon-eks-node-1.17-v20200723" # https://github.com/awslabs/amazon-eks-ami/releases
  enable_irsa                     = false
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_enabled_log_types       = ["api", "audit", "authenticator"]
  manage_cluster_iam_resources    = true
  manage_worker_iam_resources     = true
  cluster_log_retention_in_days   = "90"
  config_output_path              = "./"
  write_kubeconfig                = false

  map_roles = [
    # Administrator access to K8s
    {
      rolearn  = module.iam_assumable_roles.admin_iam_role_arn # from iam.tf
      username = "admin"
      groups   = ["system:masters"]
    },
    # Develop access to K8s
    {
      rolearn  = module.iam_assumable_roles.poweruser_iam_role_arn
      username = "edit"
      groups   = ["system:masters"]
    }
    # Fargate pods access to K8s
    # {
    #   rolearn  = module.fargate.fargate_iam_role_arn
    #   username = "system:node:{{SessionName}}"
    #   groups   = ["system:node-proxier", "system:bootstrappers", "system:nodes"]
    # }
  ]

  worker_groups = [
    {
      instance_type        = "t3a.large"
      asg_desired_capacity = "2"
      asg_min_size         = "2"
      asg_max_size         = "2"
      root_volume_size     = "20"
    }
  ]

  tags = {
    Environment = var.environment
  }
}
