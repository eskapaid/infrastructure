data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

## data for erigon1
data "template_file" "userdata_erigon1" {
  template = formatlist("%s\n",
  [file("templates/common/userdata.sh")])
  # file("templates/erigon/userdata.sh"),
  # file("templates/lighthouse/userdata.sh"))
  vars = {
    subdomain_name    = "erigon1.mainnet.eskapaid.dev"
    certificate_email = "simon@eskapa.id"
    snapshot          = "snap-0062853a88316e955"
    network           = "mainnet"
    http_apis         = "eth,debug,net,trace,web3,erigon,engine"
    http_port         = "8545"
    ws_port           = "8545"
  }
}