vpn_region    = "eu-west-3"
vpn_profile   = "terraform-vpn"
vpn_cidr      = "10.0.0.0/16"
cidrs     = {
  public  = "10.0.1.0/24"
  private = "10.0.3.0/24"
}
key_name    = "vpn"
public_key_path   = "/Users/brmm/.ssh/vpn.pub"
vpn_instance_type = "t2.nano"
vpn_ami     = "ami-1960d164"
