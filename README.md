

# OpenVPN with Terraform and Ansible on AWS

An example repository to deploy a private VPN with OpenVPN and dnsmasq running on an EC2 instance in a private cloud on AWS. Bootstrapped with Terraform and Ansible.


## Prerequisites
### 1) Install AWS CLI
* On MacOS: `brew install awscli`

For other Operating Systems see https://docs.aws.amazon.com/cli/latest/userguide/installing.html


### 2) Create an IAM. Download the key pair and configure an AWS Profile
 1. Go to https://console.aws.amazon.com/iam/home#/home
 2. Choose a username *(e.g. terraform-vpn)* and give programmatic access.
 3. Add exiting policy: *AdministratorAccess*
 4. Download the credentials and configure a profile in aws-cli
  ```bash
  aws configure --profile terraform-vpn
  aws iam get-user --profile terraform-vpn
  ```
### 3) Create a ssh key-pair to access the OpenVPN instance
```bash 
ssh-keygen -t rsa -C "your.email@example.com" -b 4096 `
chmod 600 ~/.ssh/vpn
```


## Configuration
### 1) Create a file */terraform/terraform.tfvars*
```bash
aws_region    = "eu-west-3" # Your AWS Region
aws_profile   = "terraform-vpn" # Your AWS Profile name (from step 2)
vpc_cidr      = "172.20.0.0/16" # Your private cloud CIDR
vpc_name      = "vpn network" # Name of your VPC
cidrs     = {
  public  = "172.20.3.0/24" # The public subnet CIDR
  private = "172.20.1.0/24" # The private subnet CIDR
}

vpn_public_key_path   = "~/.ssh/vpn.pub" # Path to your local ssh key pair (from step 3)
aws_vpn_instance_type = "t2.nano"
aws_vpn_ami     = "ami-1960d164"
ovpn_port      = "1194" # The OpenVPN port
```

### 2) Create a file */ansible/playbooks/roles/openvpn/default/main.yml*
```yml
vpn_cidr: 10.3.0.0/24

ovpn_network: 10.3.0.0 255.255.255.0
ovpn_push_routes :
  - 172.20.0.0 255.255.0.0

ca_dir: /home/ubuntu/ca

ca_key_country: BE
ca_key_province: BR
ca_key_city: Brussels
ca_key_org: MyOrganization
ca_key_email: your.email@organization.org
ca_key_org_unit: MyOrganizationalUnit
ca_key_name: vpn_server
```
## Setup

### 1) Add the AWS credentials to your environment
```bash
export AWS_ACCESS_KEY_ID="YOUR_AWS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET"
export AWS_DEFAULT_REGION="YOUR_AWS_REGION"
```

### 2) Bootstrap the infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply

# This will create the following configuration files for ansible :
#           ./ansible/ansible_inventory 
#           ./ansible/playbooks/group_vars/vpn_public.yml
```

### 3) Install OpenVPN on the EC2 Instance
```bash
cd ansible

# This will also add a client
ansible-playbook -i ansible_inventory playbooks/openvpn_install.yml -e username=johnappleseed -e output=/tmp/john.zip
```

### 4) Add a client to the VPN
This will download the necessary OpenVPN config and credentails as a zip file to your host's home folder. See the output from Ansible.
```bash
cd ansible
ansible-playbook -i ansible_inventory playbooks/openvpn_add_client.yml -e username=johnappleseed -e output=/tmp/john.zip
```

## TODO:
* Write a Playbook to open/close the ssh port in the security group.
* Use an elastic IP / or update `ansible_inventory` on vpn start
* Use containers instead of instances
