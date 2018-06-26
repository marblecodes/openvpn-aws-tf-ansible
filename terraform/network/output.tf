output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnet_id" {
  value = "${aws_subnet.vpc_public_subnet.id}"
}

output "private_subnet_id" {
  value = "${aws_subnet.vpc_private_subnet.id}"
}

output "public_subnet_cidr" {
  value = "${aws_subnet.vpc_public_subnet.cidr_block}"
}

output "private_subnet_cidr" {
  value = "${aws_subnet.vpc_private_subnet.cidr_block}"
}

output "private_route_table" {
  value = "${aws_route_table.vpc_private_routes.id}"
}
