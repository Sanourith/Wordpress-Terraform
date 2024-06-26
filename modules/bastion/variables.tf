variable "instance_ami" {
  type    = string
  default = "ami-0fda19674ff597992" # amazon linux
  # default = "ami-00ac45f3035ff009e" #ubuntu
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
 
variable "public_subnet_a" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ec2_sg" {
  type = string
}

variable "rds_sg" {
  type = string
}

variable "key_name" {
  type = string
}

variable "rds_sg_id" {
  type = string
}

variable "autoscaling_security_group_id" {
  type = string
}