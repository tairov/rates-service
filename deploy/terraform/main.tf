
module "vpc" {
  source  = "./modules/vpc/"
  env = var.env
}
