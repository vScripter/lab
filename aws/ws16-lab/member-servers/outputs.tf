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