resource "aws_security_group" "eth_nodes" {
  name        = "eth-nodes"
  description = "EKS Workers running Eth workloads"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "udp"
    from_port   = 12000
    to_port     = 12000
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prysm UDP"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 13000
    to_port     = 13000
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prysm TCP"
  }

  ingress {
    protocol    = "udp"
    from_port   = 9000
    to_port     = 9000
    cidr_blocks = ["0.0.0.0/0"]
    description = "Lighthouse UDP"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 9000
    to_port     = 9000
    cidr_blocks = ["0.0.0.0/0"]
    description = "Lighthouse TCP"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 30303
    to_port     = 30303
    cidr_blocks = ["0.0.0.0/0"]
    description = "Geth Discovery"
  }

  tags = {
    Name        = "eth-nodes"
    Environment = var.environment
  }
}

resource "aws_security_group" "efs" {
  name   = "efs-ingress"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [module.eks.worker_security_group_id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [module.eks.worker_security_group_id]
  }

  tags = {
    Name        = "efs-ingress"
    Environment = var.environment
  }
}