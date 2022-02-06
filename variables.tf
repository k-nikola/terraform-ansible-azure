variable "resource_group" {
  default = "TA_RG"
}
variable "azure_region" {
  default = "westeurope"
}
variable "environment" {
  default = "TerraformAnsible Demo"
}
variable "virtual_network_name" {
  default = "myVNET"
}
variable "address_space" {
  default = ["10.0.0.0/16"]
}
variable "virtual_subnet_name" {
  default = "mySubnet"
}
variable "address_prefixes" {
  default = ["10.0.1.0/24"]
}
variable "public_ip_name" {
  default = "myPublicIP"
}
variable "network_interface_name" {
  default = "myNIC"
}
variable "computer_name" {
  default = "tf"
}
variable "network_security_group_name" {
  default = "myNetSecGrp"
}
variable "admin_username" {
  description = "Username for logging into the VM as admin"
  type        = string
  sensitive   = true
}
variable "admin_password" {
  description = "Password for logging into the VM as admin"
  type        = string
  sensitive   = true
}
variable "ssh_address" {
  description = "Public IP address allowed to SSH into the VM"
  type        = string
  sensitive   = true
}
