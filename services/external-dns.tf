resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "default"

  values = [
    templatefile("${path.module}/values/external-dns.yaml", {
      role_arn    = module.external_dns_assumable_role.this_iam_role_arn
      environment = var.environment
      domain      = var.domain
      region      = var.region
    })
  ]
}

# To enable external-dns to be able to change records to Route53, we create an IAM role with policy attached with the following permissions.
# K8s ServiceAccount used by external-dns will then be able to assume this role.
module "external_dns_assumable_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 2.0"
  create_role                   = true
  role_name                     = "external-dns"
  provider_url                  = replace(var.oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:default:external-dns"]
}

resource "aws_iam_policy" "external_dns" {
  name_prefix = helm_release.external_dns.name
  description = "EKS ${helm_release.external_dns.name} policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.external_dns.json
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    sid       = "ExtDNSRoute53ChangeRecords"
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    sid    = "ExtDNSRoute53ListZones"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = ["*"]
  }
}
