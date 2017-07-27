/*
output "instance_name" {
    value = ["${module.ws16b.instance_name}"]
}

output "private_ip" {
    value = ["${module.ws16b.private_ip}"]
}

output "private_dns" {
    value = ["${module.ws16b.private_dns}"]
}

output "public_ip" {
    value = ["${module.ws16b.public_ip}"]
}

output "public_dns" {
    value = ["${module.ws16b.public_dns}"]
}
*/

output "directory_dns" {
    value = ["${aws_directory_service_directory.ms_directory.dns_ip_addresses}"]
}