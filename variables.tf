# variable "vpc_id" {
#   type = string
#   # default = module.vpc.vpc_id
# }

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

# variable "private_subnets" {
#   type = list(string)
#   # default = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
# }