resource "aws_efs_file_system" "rocketpool" {

  tags = {
    Name        = "RocketPool"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "rocketpool_a" {
  file_system_id  = aws_efs_file_system.rocketpool.id
  subnet_id       = module.vpc.private_subnets.0
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "rocketpool_b" {
  file_system_id  = aws_efs_file_system.rocketpool.id
  subnet_id       = module.vpc.private_subnets.1
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "rocketpool_c" {
  file_system_id  = aws_efs_file_system.rocketpool.id
  subnet_id       = module.vpc.private_subnets.2
  security_groups = [aws_security_group.efs.id]
}