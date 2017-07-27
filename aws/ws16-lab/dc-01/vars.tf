

variable "instance_name" {
    description = "Instance hostname"
    default = "dc-01"
}

variable "admin_password" {
    description = "Windows Admin password"
    default = "VMware1!"
}

variable "instance_count" {
    description = "number of instances to deploy"
    default = 1
}

variable "instance_region" {
    description = "Region you wish to deploy resources in"
    default = "us-east-1"
}

variable "instance_type" {
    description = "Instance type/size"
    default = "t2.micro"
}

variable "aws_key_pair" {
    default = "kevin-general"
}