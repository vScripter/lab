output "public_ip" {
    value = ["${aws_instance.ws16_base.*.public_ip}"]
}

output "public_dns" {
    value = ["${aws_instance.ws16_base.*.public_dns}"]
}

output "instance_name" {
    value = ["${aws_instance.ws16_base.*.tags.Name}"]
}

output "private_ip" {
    value = ["${aws_instance.ws16_base.*.private_ip}"]
}

output "private_dns" {
    value = ["${aws_instance.ws16_base.*.private_dns}"]
}