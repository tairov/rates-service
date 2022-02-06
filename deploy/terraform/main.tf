module "k8s" {
  source     = "./modules/k8s/"
  env        = var.env
  vpc_id     = "vpc-0be6c86446fa8a794" # euc vpc
  subnet_ids = ["subnet-0a28e01904846d487", "subnet-0b6679b7bc59e0729"]

  nodes_keypair = var.eks_nodes_keypair
}
