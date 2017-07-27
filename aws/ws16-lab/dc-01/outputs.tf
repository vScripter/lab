output "instance_name" {
    value = ["${aws_instance.ws16b.tags.Name}"]
}

output "private_ip" {
    value = ["${aws_instance.ws16b.private_ip}"]
}

output "private_dns" {
    value = ["${aws_instance.ws16b.private_dns}"]
}

output "public_ip" {
    value = ["${aws_instance.ws16b.public_ip}"]
}

output "public_dns" {
    value = ["${aws_instance.ws16b.public_dns}"]
}