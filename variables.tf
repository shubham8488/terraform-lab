variable "rg_name" {
  type        = string
  description = "Name of the Resource Group"
}

variable "rg_location" {
  default = "EastUS"
}

variable "vnet_name" {
  default = "jumpbox_vnet"
}

variable "address_space" {
  default = ["172.16.0.0/16"]
}

variable "subnet_name" {
  default = "jumpbox_subnet"
}

variable "address_prefixes" {
  default = ["172.16.10.0/24"]
}

variable "vm_name" {
  default = "jump-box-01"
}

variable "vm_username" {
  default = "ubuntu"
}

variable "custom_image_name" {
  default = "golden-image-v432"
}
variable "custom_image_resource_group_name" {
  default = "resource-group-1"
}

