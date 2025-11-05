  module "vpc" {
    source          = "../../modules/vpc"
    vpc_cidr        = var.vpc_cidr
    public_subnets  = var.public_subnets
    private_subnets = var.private_subnets
    azs             = var.azs
    env             = var.env
  }

  module "app" {
    source         = "../../modules/ec2"
    vpc_id         = module.vpc.vpc_id
    private_subnet = module.vpc.private_subnets[0]
    public_subnet  = module.vpc.public_subnets[0]
    ami            = var.ami
    key_name       = var.key_name
    env            = var.env
    instance_count_app = var.instance_count_app
    instance_count_db = var.instance_count_db
  }

