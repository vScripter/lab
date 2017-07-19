/*variable "instance_name" {
    description = "Name of the instance"
}*/

variable "ws_hostname_prefix" {
    description = "Base hostname prefix for Windows Servers"
    default = "ws"
}

variable "nix_hostname_prefix" {
    description = "Base hostname prefix for Linux Servers"
    default = "ub"
}