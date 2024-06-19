


output "db_instance_endpoint" {
  value = aws_db_instance.wordpress_db.endpoint
}
# output "db_instance_replica_endpoint" {
#   value = aws_db_instance.wordpress_db_replica
# }

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

# output "db_subnet_group_id" {
#   value = aws_db_subnet_group.main.id
# }