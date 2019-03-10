

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
### 1) Modify the config file as you wish */config.json*
```json
{
  "REGION": "eu-west-1",
  "PROFILE": "terraform-vpn",

  "VPN_INSTANCE_TYPE": "t3.micro",
  "VPN_AMI": "ami-00035f41c82244dab",
  "VPN_SSH_PUBLIC_KEY": "~/.ssh/vpn.pub",
  "VPN_SSH_PRIVATE_KEY": "~/.ssh/vpn",
  "OVPN_PORT": "1194",

  "VPC_CIDR": "172.20.0.0/16",
  "VPC_CIDRS": {
    "public": "172.20.3.0/24",
    "private": "172.20.1.0/24"
  }
}
```

### 2) Modify the default vars of the openvpn ansible role as you wish */ansible/roles/openvpn/default/main.yml*
```yml
ovpn_cidr: 10.3.0.0/24
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
terraform plan --var-file ../config.json
terraform apply --var-file ../config.json
```

### 3) Wait till the EC2 is ready

### 4) Install OpenVPN on the EC2 Instance
This will download a zip file with client openvpn configuration and keys to your host.
```bash
cd ansible

# This will also add a client
ansible-playbook -i inventory openvpn_install.yml -e "username=john" -e "output=/tmp/john_vpn.zip"
```

### 4) Add an additional client to the VPN
This will download a zip file with client openvpn configuration and keys to your host.
```bash
cd ansible
ansible-playbook -i inventory openvpn_add_client.yml -e "username=john" -e "output=/tmp/john_vpn.zip"

```

## Reprovision the EC2
If you want to recreate the vpn server with a new IP adress and new correct configuration, run these commands:
```bash
# taint the ec2 instance and ansible inventory generation script, this means it will be destroyed and recreated

cd terraform
terraform taint aws_instance.vpn 
terraform taint null_resource.vpn_generate_inventory
terraform apply --var-file ../config.json -auto-approve

# wait till the instance get up ...

# provision again with ansible
cd ../ansible
ansible-playbook -i inventory openvpn_install.yml -e "username=bram" -e "output=/Users/brmm/Desktop/bram_vpn.zip"
```

## Problems:
* Redirecting all traffic through the VPN is not working properly yet.
* If you use tunnelblick on Mac on Sierra or higher you might have DNS issues see this [github issue](https://github.com/Tunnelblick/Tunnelblick/issues/401)

## TODO:
* Fix traffic redirect through the tunnel


