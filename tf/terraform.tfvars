aws_region    = "eu-west-3"
aws_profile   = "terraform-vpn"
vpc_cidr      = "172.20.0.0/16"
ovpn_port      = "1194"
cidrs     = {
  public  = "172.20.3.0/24"
  private = "172.20.1.0/24"
}
key_name    = "vpn"
public_key_path   = "/Users/brmm/.ssh/vpn.pub"
aws_vpn_instance_type = "t2.nano"
aws_vpn_ami     = "ami-1960d164"
