### VPC
#>-------------------------
variable "vpc_cidr" {
  type        = string
  description = ""
  default     = "10.0.0.0/16"
}
variable "vpc_name" {
  type    = string
  default = "matt-vpc"
}

### SUBNETS
#>-------------------------
variable "az" {
  type    = list(string)
  default = ["eu-west-3a", "eu-west-3b"]
}
variable "sub1name" {
  type    = string
  default = "public-a"
}
# variable "az_2" {
#   type    = string
#   default = "eu-west-3b"
# }
variable "sub2name" {
  type    = string
  default = "public-b"
}
variable "priv1name" {
  type    = string
  default = "app-a"
}
variable "priv2name" {
  type    = string
  default = "app-b"
}

### BASTION & WORDPRESS
#>-------------------------
variable "instance_ami" {
  type    = string
  default = "ami-00ac45f3035ff009e"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "private_subnets" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "rds_sg_id" {
  type = string
}


### DB RDS
#>-------------------------
variable "vpc_id" {
  type = string
}
variable "allocated_storage" {
  type    = number
  default = 20
}
variable "storage_type" {
  type    = string
  default = "gp2"
}
variable "engine" {
  type    = string
  default = "mysql"
}
variable "engine_version" {
  type    = string
  default = "8.0"
}
variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "db_name" {
  type    = string
  default = "wordpressdb"
}
variable "db_username" {
  type      = string
  sensitive = true
  default   = "sanou"
}
variable "db_user_password" {
  type      = string
  sensitive = true
  default   = "password"
}

variable "db_endpoint" {
  type = string
}

variable "domain" {
  type        = string
  description = "DNS WP"
  default     = "sanou.cloudns.be"
}

variable "subdomain" {
  type    = string
  default = "tf.sanou.cloudns.be"
}

# RDS primary instance identity
variable "primary_rds_identifier" {
  type        = string
  default     = "wordpress-rds-instance"
  description = "Identifier of primary RDS instance"
}
# RDS replica identity
variable "replica_rds_identifier" {
  type        = string
  default     = "wordpress-rds-instance-replica"
  description = "Identifier of replica RDS instance"
}


