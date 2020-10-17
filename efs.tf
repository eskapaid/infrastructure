resource "aws_efs_file_system" "rocketpool" {

  tags = {
    Name        = "RocketPool"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "rocketpool" {
  for_each        = toset(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.rocketpool.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}