variable "instance_name" {
    description = "Instance Name (tag)"
    default = "ws16c"
}

variable "admin_password" {
    description = "Windows Admin password"
}

variable "instance_type" {
    description = "Instance type/size"
    default = "t2.micro"
}

variable "instance_region" {
    description = "AWS Region"
    default = "us-east-1"
}

variable "aws_key_pair" {
    description = "Key-Pair to associate to the instance"
    default = "kevin-general"
}

variable "instance_count" {
    description = "number of instances to deploy"
    default = 1
}

