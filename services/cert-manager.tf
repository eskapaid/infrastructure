resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace  = "default"
  version    = "1.1.0"

  values = [
    templatefile("${path.module}/values/cert-manager.yaml", {
      role_arn = module.iam_assumable_role_admin.this_iam_role_arn
    })
  ]
}

# cert-manager needs to be able to add records to Route53 in order to solve the DNS01 challenge.
# To enable this, we create an IAM role with policy attached with the following permissions.
# K8s ServiceAccount used by cert-manager will then be able to assume this role.

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 2.0"
  create_role                   = true
  role_name                     = "cert-manager"
  provider_url                  = replace(var.oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.services.metadata.0.name}:cert-manager"]
}

resource "aws_iam_policy" "cert_manager" {
  name_prefix = helm_release.cert_manager.name
  description = "EKS ${helm_release.cert_manager.name} policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.cert_manager.json
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    sid       = "CertManagerRoute53GetChange"
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }
  statement {
    sid    = "CertManagerRoute53Records"
    effect = "Allow"
    actions = ["route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    sid    = "CertManagerRoute53ListZones"
    effect = "Allow"
    actions = ["route53:ListHostedZonesByName",
    "route53:ListHostedZones"]
    resources = ["*"]
  }
}
