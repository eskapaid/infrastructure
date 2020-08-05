# Create TF Cloud role with basic policy attached
resource "aws_iam_role" "terraform_cloud" {
  name               = "TerraformCloud"
  description        = "Role used for Terraform Cloud runs - allows full admin privilages"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.tf_role_policy.json
}

# Attach admin policy to terraform role
resource "aws_iam_role_policy_attachment" "terraform_cloud" {
  role       = aws_iam_role.terraform_cloud.name
  policy_arn = data.aws_iam_policy.admin_policy.arn
}