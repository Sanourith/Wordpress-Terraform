
 
resource "aws_instance" "bastion" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_a
  vpc_security_group_ids = [aws_security_group.bastion_sg.id, var.rds_sg_id, var.autoscaling_security_group_id]
  tags = {
    Name = "Bastion"
  }
  user_data = <<-EOF
            #! /bin/bash
            apt-get update
            apt-get install -y htop
            EOF
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for bastion"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------
###
###
###
###
###
###
# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------


resource "aws_security_group" "liens_bastion" {
  name        = "bastion-link"
  description = "SG EC2-RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.ec2_sg]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.rds_sg]
  }
}