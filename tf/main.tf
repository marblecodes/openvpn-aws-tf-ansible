######## --------------------- AWS PROVIDER
provider "aws" {
  region  = "${var.vpn_region}"
  profile = "${var.vpn_profile}"
}

######## --------------------- VIRTUAL PRIVATE NETWORK
resource "aws_vpc" "vpn_vpc" {
  cidr_block           = "${var.vpn_cidr}"
  enable_dns_hostnames = true              # A boolean flag to enable DNS hostnames in the VPC

  tags {
    Name = "VPN VPC"
  }
}

######## --------------------- INTERNET GATEWAY
resource "aws_internet_gateway" "vpn_igw" {
  vpc_id = "${aws_vpc.vpn_vpc.id}"

  tags {
    Name = "VPN IG"
  }
}

######## --------------------- ROUTE TABLES
resource "aws_route_table" "vpn_public_routes" {
  vpc_id = "${aws_vpc.vpn_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpn_igw.id}"
  }

  tags {
    Name = "VPN PUBLIC ROUTES"
  }
}

resource "aws_default_route_table" "vpn_private_routes" {
  default_route_table_id = "${aws_vpc.vpn_vpc.default_route_table_id}"

  tags {
    Name = "VPN PRIVATE ROUTES"
  }
}

# ######## --------------------- ELASTIC IP
# resource "aws_eip" "vpn_eip" {
#   vpc = true
#   instance = "${aws_instance.vpn_.id}"
# }

######## --------------------- SUBNET
resource "aws_subnet" "vpn_public_subnet" {
  vpc_id                  = "${aws_vpc.vpn_vpc.id}"
  cidr_block              = "${var.cidrs["public"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "VPN PUBLIC SUBNET 1"
  }
}

resource "aws_subnet" "vpn_private_subnet" {
  vpc_id                  = "${aws_vpc.vpn_vpc.id}"
  cidr_block              = "${var.cidrs["private"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "VPN PRIVATE SUBNET 1"
  }
}

######## --------------------- SUBNET ASSOCIATION
resource "aws_route_table_association" "vpn_public_assoc" {
  subnet_id      = "${aws_subnet.vpn_public_subnet.id}"
  route_table_id = "${aws_route_table.vpn_public_routes.id}"
}

resource "aws_route_table_association" "vpn_private_assoc" {
  subnet_id      = "${aws_subnet.vpn_private_subnet.id}"
  route_table_id = "${aws_default_route_table.vpn_private_routes.id}"
}

######## --------------------- SECURITY GROUPS
resource "aws_security_group" "vpn_default_sg" {
  name   = "VPN DEFAULT SG"
  vpc_id = "${aws_vpc.vpn_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.vpn_port}"
    to_port     = "${var.vpn_port}"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

######## --------------------- KEY PAIR
resource "aws_key_pair" "vpn_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

######## --------------------- VPN INSTANCE
resource "aws_instance" "vpn" {
  instance_type = "${var.vpn_instance_type}"
  ami           = "${var.vpn_ami}"

  tags {
    Name = "VPN"
  }

  key_name               = "${aws_key_pair.vpn_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.vpn_default_sg.id}"]
  subnet_id              = "${aws_subnet.vpn_public_subnet.id}"

  ###### Generate an Ansible inventory file
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > ../ansible/ansible_inventory
[vpn]
${aws_instance.vpn.public_ip}
EOF
EOD
  }

  ####### Generate an Ansible variable file
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > ../ansible/vpn_tf_vars.yml
aws_region: ${var.vpn_region}
vpn_instance_id: ${aws_instance.vpn.id}
vpn_gateway: ${aws_instance.vpn.private_ip}
vpn_port: ${var.vpn_port}
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.vpn.id} --profile ${var.vpn_profile} && echo 'VPN Instance is up and running!'"
  }
}

