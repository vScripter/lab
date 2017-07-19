# Need to figure out how to better parameterize spinning up multiple servers

# ws16c-01
output "01_instance_name" {
    value = ["${module.ws16c-01.instance_name}"]
}

output "01_public_ip" {
    value = ["${module.ws16c-01.public_ip}"]
}

output "01_public_dns" {
    value = ["${module.ws16c-01.public_dns}"]
}

# ws16c-02
output "02_instance_name" {
    value = ["${module.ws16c-02.instance_name}"]
}

output "02_public_ip" {
    value = ["${module.ws16c-02.public_ip}"]
}

output "02_public_dns" {
    value = ["${module.ws16c-02.public_dns}"]
}