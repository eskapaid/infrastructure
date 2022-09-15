module "iam_assumable_roles" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles"
  version = "~> 2.0"

  trusted_role_arns = [
    data.aws_caller_identity.current.account_id,
  ]

  create_admin_role       = true
  admin_role_name         = "AdminAccess"
  admin_role_requires_mfa = true

  create_poweruser_role = false
  poweruser_role_name   = "DevAccess"
  # poweruser_role_policy_arns = ["arn:aws:iam::aws:policy/AWSSupportAccess"]
  poweruser_role_requires_mfa = false # should be true eventually

  create_readonly_role       = false
  readonly_role_requires_mfa = false
}