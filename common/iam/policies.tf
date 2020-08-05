data "aws_iam_policy" "viewonly_policy" {
  arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

data "aws_iam_policy" "poweruser_policy" {
  arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

data "aws_iam_policy" "admin_policy" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# to be used by users (requires MFA)
data "aws_iam_policy_document" "user_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "true",
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"

      values = [
        "true",
      ]
    }

    condition {
      test     = "NumericLessThan"
      variable = "aws:MultiFactorAuthAge"

      values = [
        "54000",
      ]
    }
  }
}

# to be used by various services (no MFA requirements)
data "aws_iam_policy_document" "service_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "true",
      ]
    }
  }
}

# used by TF Cloud. Restrict to terraform user
data "aws_iam_policy_document" "tf_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.terraform_cloud.name}"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "true",
      ]
    }
  }
}