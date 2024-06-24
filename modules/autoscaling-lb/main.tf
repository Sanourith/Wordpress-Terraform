### AUTO SCALING GROUP

resource "aws_key_pair" "app_key" {
  key_name   = "app-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Template file
data "template_file" "install_wordpress" {
  template = file("./wordpress_aws.sh")
  vars = {
    db_username      = var.db_username
    db_user_password = var.db_user_password
    db_name          = var.db_name
    db_endpoint      = var.db_endpoint
  }
}

resource "aws_launch_template" "Wordpress" {
  name                   = "app-launch-template"
  image_id               = var.instance_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.app_key.key_name
  user_data              = base64encode(file("wordpress_aws.sh"))
  vpc_security_group_ids = [aws_security_group.sg_app_lb.id, var.rds_sg_id, aws_security_group.wordpress_sg.id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "app-template"
  }
  #   depends_on = [module.aws_db_instance.wordpress_db]
}

resource "aws_autoscaling_group" "Wordpress" {
  name                = "auto-scaling-app"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.public_subnets
  target_group_arns   = [aws_lb_target_group.cibles.arn]
  launch_template {
    id      = aws_launch_template.Wordpress.id
    version = aws_launch_template.Wordpress.latest_version
  }
  tag {
    key                 = "Name"
    value               = "auto-scaling"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.Wordpress.name
  lb_target_group_arn    = aws_lb_target_group.cibles.arn
}
# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress_sg"
  description = "Allow HTTP access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #connect DB
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.rds_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Wordpress-SG"
  }
}


# resource "aws_security_group" "EC2_to_RDS" {
#     name = "ec2_to_rds"
#     description = "Relie notre SG-wordpress à SG-rds"
#     vpc_id      = var.vpc_id
# }



###################### LOAD BALANCER 

resource "aws_lb" "lb_app" {
  name                       = "load-balancer"
  internal                   = false
  load_balancer_type         = "application"
  ip_address_type            = "ipv4"
  subnets                    = var.public_subnets
  security_groups            = [aws_security_group.sg_app_lb.id]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "cibles" {
  name        = "tf-app-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 15
    matcher             = 200
    path                = "/"
    timeout             = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb_app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cibles.arn
  }
}


# ## Joindre l' instance A à la zone de disponibilté A au groupe cible
resource "aws_autoscaling_attachment" "app_tg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.Wordpress.name
  lb_target_group_arn    = aws_lb_target_group.cibles.arn
}

# ## Joindre l' instance B à la zone de disponibilté B au groupe cible
# resource "aws_lb_target_group_attachment" "appb_tg_attachment" {
#   target_group_arn = aws_lb_target_group.cibles.arn
#   target_id        = aws_autoscaling_group.Wordpress.id
#   port             = 80
# }

resource "aws_security_group" "sg_app_lb" {
  name   = "sg_loadbalancer"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "SG-lb"
  }
}