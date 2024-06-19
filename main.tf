
module "vpc" {
  source = "./modules/vpc"
}

# module "security_groups" {
#   source = "./modules/security_groups"
#   # vpc_id = module.vpc_id
# }

module "rds" {
  source               = "./modules/rds"
  private_subnets      = module.vpc.private_subnets
  db_subnet_group_name = module.vpc.db_subnet_group_name
  vpc_id               = module.vpc.vpc_id
  # autoscaling_security_group_id = module.autoscaling.autoscaling_security_group_id
}

module "autoscaling" {
  source          = "./modules/autoscaling-lb"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  rds_sg_id       = module.rds.rds_sg_id
  db_endpoint     = module.rds.db_instance_endpoint
  depends_on      = [module.rds]
}

# module "load_balancer" {
#   source = "./modules/load_balancer"
# }

module "bastion" {
  source          = "./modules/bastion"
  vpc_id          = module.vpc.vpc_id
  public_subnet_a = module.vpc.public_subnets[0]
  ec2_sg          = module.autoscaling.autoscaling_security_group_id
  rds_sg          = module.rds.rds_sg_id
  key_name        = module.autoscaling.key_name
}

