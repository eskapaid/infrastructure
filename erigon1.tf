module "erigon1_mainnet" {
  source             = "app.terraform.io/eskapaid/ubuntu/aws"
  version            = "1.0.2-beta"
  name               = "erigon1-mainnet"
  subdomain_name     = "erigon1.mainnet.eskapaid.dev"
  zone_name          = "eskapaid.dev"
  instance_type      = "m5n.2xlarge"
  env                = var.environment
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.public_subnets[2]
  security_group_ids = [aws_security_group.erigon1.id]
  enable_eip         = true
  enable_dns         = true
  enable_monitoring  = false
  pd_webhook         = ""
  user_data          = data.template_file.userdata_erigon1.rendered
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 60
    }
  ]
  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 3000
      iops        = 16000
      snapshot_id = "snap-0062853a88316e955"
    }
  ]
}
