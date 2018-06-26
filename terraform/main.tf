variable "aws_region" {}
variable "aws_profile" {}
variable "vpc_cidr" {}
variable "vpc_name" {}

variable "cidrs" {
  type = "map"
}

variable "vpn_public_key_path" {}
variable "aws_vpn_instance_type" {}
variable "aws_vpn_ami" {}
variable "ovpn_port" {}

module "network" {
  source = "./network"

  aws_region  = "${var.aws_region}"
  aws_profile = "${var.aws_profile}"
  vpc_name    = "${var.vpc_name}"
  vpc_cidr    = "${var.vpc_cidr}"
  cidrs       = "${var.cidrs}"
}

module "vpn_instance" {
  source = "./vpn"

  vpc_id                = "${module.network.vpc_id}"
  subnet_id             = "${module.network.public_subnet_id}"
  private_route_table   = "${module.network.private_route_table}"
  vpc_cidr              = "${var.vpc_cidr}"
  vpn_public_key_path   = "${var.vpn_public_key_path}"
  aws_vpn_instance_type = "${var.aws_vpn_instance_type}"
  aws_vpn_ami           = "${var.aws_vpn_ami}"
  ovpn_port             = "${var.ovpn_port}"
}

resource "null_resource" "generate_inventory" {
  provisioner "local-exec" {
    command = <<EOD
    cat <<EOF > ../ansible/playbooks/group_vars/vpn_public.yml
aws_instance_id: ${module.vpn_instance.vpn_instance_id}
vpn_gateway: ${module.vpn_instance.private_ip}
ovpn_port: ${var.ovpn_port}
vpc_cidr: ${var.vpc_cidr}
EOF
EOD
  }

  provisioner "local-exec" {
    command = <<EOD
    cat <<EOF > ../ansible/ansible_inventory
aws_region=${var.aws_region}

[vpn_public]
${module.vpn_instance.public_ip}

[vpn]
${module.vpn_instance.private_ip}
EOF
EOD
  }
}
