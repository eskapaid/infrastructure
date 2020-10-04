resource "aws_efs_file_system" "rocketpool" {

  tags = {
    Name        = "RocketPool"
    Environment = var.environment
  }
}