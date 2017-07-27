output "instance_name" {
    value = ["${module.ws16.instance_name}"]
}

output "private_ip" {
    value = ["${module.ws16.private_ip}"]
}

output "private_dns" {
    value = ["${module.ws16.private_dns}"]
}

output "public_ip" {
    value = ["${module.ws16.public_ip}"]
}

output "public_dns" {
    value = ["${module.ws16.public_dns}"]
}