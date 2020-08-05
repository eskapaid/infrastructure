# Credentials of which are used by TF Cloud
resource "aws_iam_user" "terraform_cloud" {
  name = "terraform"
}

# Permissions to assume role
data "aws_iam_policy_document" "terraform_user_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.terraform_cloud.arn]
  }
}

# Attach policy to user
resource "aws_iam_user_policy" "terraform_cloud" {
  name   = "terraform"
  user   = aws_iam_user.terraform_cloud.name
  policy = data.aws_iam_policy_document.terraform_user_policy.json
}