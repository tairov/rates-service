module "vpc" {
  source = "./modules/vpc/"
  env    = var.env
}

module "k8s" {
  source = "./modules/k8s/"
  env    = var.env
  #vpc_id = module.vpc.vpc_01_id
  subnet_ids = [module.vpc.subnet_01_id, module.vpc.subnet_02_id]
}
