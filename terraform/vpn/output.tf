output "public_ip" {
  value = "${aws_instance.vpn.public_ip}"
}

output "private_ip" {
  value = "${aws_instance.vpn.private_ip}"
}

output "vpn_instance_id" {
  value = "${aws_instance.vpn.id}"
}

output "vpn_sg_id" {
  value = "${aws_security_group.vpn_sg.id}"
}
