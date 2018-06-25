######## --------------------- SECURITY GROUPS
resource "aws_security_group" "vpn_sg" {
  name   = "VPN DEFAULT SG"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.ovpn_port}"
    to_port     = "${var.ovpn_port}"
    protocol    = "udp"
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
  key_name   = "vpn"
  public_key = "${file(var.vpn_public_key_path)}"
}

######## --------------------- VPN INSTANCE
resource "aws_instance" "vpn" {
  instance_type = "${var.aws_vpn_instance_type}"
  ami           = "${var.aws_vpn_ami}"

  tags {
    Name = "VPN"
  }

  key_name               = "${aws_key_pair.vpn_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.vpn_sg.id}"]
  subnet_id              = "${var.public_subnet_id}"
}
