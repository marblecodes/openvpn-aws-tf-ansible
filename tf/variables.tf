variable "vpn_region" {}
variable "vpn_profile" {}
variable "vpn_cidr" {}
variable "vpn_port" {}

variable "cidrs" {
  type = "map"
}

data "aws_availability_zones" "available" {}
variable "key_name" {}
variable "public_key_path" {}
variable "vpn_instance_type" {}
variable "vpn_ami" {}
