resource "aws_security_group" "eth_nodes" {
  name        = "eth-nodes"
  description = "EKS Workers running Eth workloads"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "udp"
    from_port   = 12000
    to_port     = 12000
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 13000
    to_port     = 13000
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "udp"
    from_port   = 9000
    to_port     = 9000
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 9000
    to_port     = 9000
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}