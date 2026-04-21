provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
  name_prefix     = var.environment
  tags            = var.common_tags
}

module "nlb" {
  source = "./modules/nlb"

  vpc_id            = module.vpc.vpc_id
  public_subnets    = module.vpc.public_subnet_ids
  name              = "${var.environment}-${var.project_name}-nlb"
  target_group_name = "${var.environment}-tg"
  tags              = var.common_tags
}

module "route53" {
  source = "./modules/route53"

  zone_id     = var.zone_id
  record_name = var.route53_record_name
  nlb_dns     = module.nlb.nlb_dns
}

module "eks" {
  source = "./modules/eks"

  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  instance_types  = var.node_instance_types
  desired_size    = var.node_desired_size
  min_size        = var.node_min_size
  max_size        = var.node_max_size
  tags            = var.common_tags
}
