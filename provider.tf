terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
  #   shared_credentials_files = ["~/.aws/credentials"]
}
 
# provider "http" {
# }