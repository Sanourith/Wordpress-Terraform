output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}


output "db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}
# output "db_instance_replica_endpoint" {
#   value = aws_db_instance.wordpress_db_replica
# }
 
output "rds_sg_id" {
  value = module.rds.rds_sg_id
}