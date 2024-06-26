output "vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "public_subnets" {
  value = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

output "private_subnets" {
  value = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}
 
output "db_subnet_group_id" {
  value = aws_db_subnet_group.main.id
}
output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
}