
# PRIMARY RDS instance
resource "aws_db_instance" "wordpress_db" {
  identifier             = var.primary_rds_identifier
  availability_zone      = var.az[0]
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_user_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_sg.id] #var.autoscaling_sg_id]
  skip_final_snapshot    = true

  lifecycle {
    ignore_changes = [password]
  }
  tags = {
    Name = "App-DB"
  }
}

# # REPLICA RDS instance
# resource "aws_db_instance" "wordpress_db_replica" {
#   replicate_source_db    = var.primary_rds_identifier
#   identifier             = var.replica_rds_identifier
#   availability_zone      = var.az[1]
#   # allocated_storage      = var.allocated_storage
#   storage_type           = var.storage_type
#   engine                 = var.engine
#   engine_version         = var.engine_version
#   instance_class         = var.instance_class
#   vpc_security_group_ids = [aws_security_group.rds_sg.id]
#   db_subnet_group_name   = aws_db_subnet_group.main.name
#   skip_final_snapshot    = true

#   depends_on = [aws_db_instance.wordpress_db]
# }
# ------------------------------------------------
# ------------------------------------------------

# resource "aws_db_subnet_group" "main" {
#   name       = "db-subnet-group"
#   subnet_ids = [
#     var.private_subnets[0],
#     var.private_subnets[1]
#   ]

#   tags = {
#     Name = "main-db-subnet-group"
#   }
# }

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    # security_groups   = [var.autoscaling_security_group_id]      # [aws_security_group.app_sg.id]
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}