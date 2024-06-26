# variable "vpc_id" {
#   type = string
#   # default = module.vpc.vpc_id
# }

variable "db_name" {
  type = string
  # default = "wordpressdb"  # export TF_VAR_db_name="wordpressdb"
}
variable "db_username" {
  type      = string
  sensitive = true
  # default   = "sanou"  # export TF_VAR_db_username="sanou"
}
variable "db_user_password" {
  type      = string
  sensitive = true
  # default   = "password"  # export TF_VAR_db_user_password="password"
}
 
# variable "private_subnets" {
#   type = list(string)
#   # default = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
# }