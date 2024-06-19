### VPC
#>-------------------------
variable "vpc_cidr" {
  type        = string
  description = ""
  default     = "10.0.0.0/16"
}
variable "vpc_name" {
  type    = string
  default = "wordpress-vpc"
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
# variable "db_subnet_group_id" {
#   type = string
# }