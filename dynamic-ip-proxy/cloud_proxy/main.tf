provider "aws" {
  region = "ap-south-1"
}

module "aws_proxy" {
  source = "../modules/aws_proxy"  # Path to the aws_proxy module

  # Pass through input variables from the entry point to the module
  allowed_ips = var.allowed_ips
  username    = var.username
  password    = var.password
  life_minutes  = var.life_minutes
  key_name    = var.key_name
  subnet_id   = var.subnet_id
}




