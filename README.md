# OpenVPN with Terraform and Ansible on AWS

A declarative way to create an isolated infrastructure in the cloud with openvpn access

* Install aws cli 
** brew install awscli

* Create an IAM with admin rights
** Go to https://console.aws.amazon.com/iam/home#/home
** Choose a user name
** Programmtic access
** Attach existing policies directly
** Choose AdministratorAccess
** Click next and download the credentails (important)

* Add profile to aws cli profile
`aws configure --profile terraform-vpn`
`aws iam get-user --profile terraform-vpn`

* Create an keypair for the vpn instance
` keygen `
` chmod 600 ~/.ssh/vpn `
