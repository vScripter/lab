output "directory_dns" {
    value = ["${aws_directory_service_directory.ms_directory.dns_ip_addresses}"]
}