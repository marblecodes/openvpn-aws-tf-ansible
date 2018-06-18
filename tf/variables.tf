variable "aws_region" {}
variable "aws_profile" {}
variable "vpc_cidr" {}
variable "ovpn_port" {}

variable "cidrs" {
  type = "map"
}

data "aws_availability_zones" "available" {}
variable "key_name" {}
variable "public_key_path" {}
variable "aws_vpn_instance_type" {}
variable "aws_vpn_ami" {}
