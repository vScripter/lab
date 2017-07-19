output "nix_instance_public_ip" {
    value = ["${aws_instance.ubuntu-dev.*.public_ip}"]
}

output "nix_instance_public_dns" {
    value = ["${aws_instance.ubuntu-dev.*.public_dns}"]
}

output "ws_instance_public_ip" {
    value = ["${aws_instance.ws16-core.*.public_ip}"]
}

output "ws_instance_public_dns" {
    value = ["${aws_instance.ws16-core.*.public_dns}"]
}