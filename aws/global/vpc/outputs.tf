output "subnet_id" {
    value = "${aws_subnet.10-10-1-0_24.id}"
}

output "vpc_id" {
    value = "${aws_vpc.cloud-lab.id}"
}

output "instance_sg" {
    value = "${aws_security_group.instance.id}"
}