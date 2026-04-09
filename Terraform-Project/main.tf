provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr        = "10.10.0.0/16"
  public_subnets  = ["10.10.0.0/19", "10.10.32.0/19", "10.10.64.0/19"]
  private_subnets = ["10.10.96.0/19", "10.10.128.0/19", "10.10.160.0/19"]
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "nlb" {
  source = "./modules/nlb"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
}

module "route53" {
  source = "./modules/route53"

  zone_id = var.zone_id
  nlb_dns = module.nlb.nlb_dns
}