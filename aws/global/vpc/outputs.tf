output "subnet_10-10-1-0_24_id" {
    value = "${aws_subnet.10-10-1-0_24.id}"
}

output "subnet_10-10-2-0_24_id" {
    value = "${aws_subnet.10-10-2-0_24.id}"
}

output "vpc_id" {
    value = "${aws_vpc.cloud-lab.id}"
}

output "instance_sg" {
    value = "${aws_security_group.instance.id}"
}