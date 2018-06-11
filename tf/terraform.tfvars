vpn_region    = "eu-west-3"
vpn_profile   = "terraform-vpn"
vpn_cidr      = "10.1.0.0/16"
vpn_port      = "1194"
cidrs     = {
  public  = "10.1.1.0/24"
  private = "10.1.3.0/24"
}
key_name    = "vpn"
public_key_path   = "/Users/brmm/.ssh/vpn.pub"
vpn_instance_type = "t2.nano"
vpn_ami     = "ami-1960d164"
