variable "OVPN_PORT" {}
variable "VPN_SSH_PUBLIC_KEY" {}
variable "VPN_SSH_PRIVATE_KEY" {}
variable "VPN_INSTANCE_TYPE" {}
variable "VPN_AMI" {}

# SECURITY GROUPS
# =================================================================================
resource "aws_security_group" "vpn_sg" {
  name   = "VPN DEFAULT SG"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.OVPN_PORT
    to_port     = var.OVPN_PORT
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# KEY PAIR
# =================================================================================
resource "aws_key_pair" "vpn_auth" {
  key_name   = "vpn"
  public_key = file(var.VPN_SSH_PUBLIC_KEY)
}

# EC2 INSTANCE
# =================================================================================
resource "aws_instance" "vpn" {
  instance_type = var.VPN_INSTANCE_TYPE
  ami           = var.VPN_AMI

  tags = {
    Name = "vpn"
  }

  key_name                    = aws_key_pair.vpn_auth.id
  vpc_security_group_ids      = [aws_security_group.vpn_sg.id]
  subnet_id                   = aws_subnet.vpc_public_subnet.id
  associate_public_ip_address = true
  source_dest_check           = false
}

# GENERATE ANSIBLE INVENTORY
# =================================================================================
resource "local_file" "ansible_inventory" {
  content = <<EOF
[vpn_public]
${aws_instance.vpn.public_ip}

[vpn_public:vars]
aws_region=${data.aws_region.current.name}
ansible_ssh_private_key_file=${var.VPN_SSH_PRIVATE_KEY}
public_ip=${aws_instance.vpn.public_ip}
vpn_gateway=${aws_instance.vpn.private_ip}
ovpn_port=${var.OVPN_PORT}
vpc_cidr=${aws_vpc.vpc.cidr_block}
hostname=vpn
EOF

  filename = "${path.module}/../ansible/inventory"
}