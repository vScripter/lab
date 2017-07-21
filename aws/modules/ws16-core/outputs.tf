output "public_ip" {
    value = ["${aws_instance.ws16_core.*.public_ip}"]
}

output "public_dns" {
    value = ["${aws_instance.ws16_core.*.public_dns}"]
}

output "instance_name" {
    value = ["${aws_instance.ws16_core.*.tags.Name}"]
}

output "private_ip" {
    value = ["${aws_instance.ws16_core.*.private_ip}"]
}

output "private_dns" {
    value = ["${aws_instance.ws16_core.*.private_dns}"]
}