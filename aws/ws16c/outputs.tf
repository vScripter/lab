output "instance_name" {
    value = ["${module.ws16c-01.instance_name}"]
}

output "private_ip" {
    value = ["${module.ws16c-01.private_ip}"]
}

output "private_dns" {
    value = ["${module.ws16c-01.private_dns}"]
}

output "public_ip" {
    value = ["${module.ws16c-01.public_ip}"]
}

output "public_dns" {
    value = ["${module.ws16c-01.public_dns}"]
}