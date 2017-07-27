variable "admin_password" {
    description = "Windows Admin password"
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