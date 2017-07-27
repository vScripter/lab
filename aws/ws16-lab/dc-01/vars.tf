 /*terragrunt {

  include {
    path = "${find_in_parent_folders()}"
  }

  dependencies {
    paths = ["../vpc", "../mysql", "../redis"]
  }

}*/

variable "dc_config" {
    type    = "map"
    default = {
        instance_name   = "dc-01"
        instance_count  = 1
        instance_region = "us-east-1"
        instance_type   = "t2.micro"
        aws_key_pair    = "kevin-general"
    }
}

variable "admin_password" {
    description = "Windows Admin password"
}