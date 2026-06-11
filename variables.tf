variable "client_id" {
  type = string
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "my_Vnet" {
  type = string
}

variable "my_nic" {
  type = string
}

variable "my_Subnet" {
  type = string
}

variable "my_VM" {
  type = string
}

variable "Windows_VM" {
  type = string
}
variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "Environment" {
  type = string
}

variable "Owner" {
  type = string
}

variable "Project" {
  type = string
}

variable "my_pip" {
  type = string
}

variable "my_nsg" {
  type = string
}

variable "vm_count" {
  type = string
}

variable "instance_type" {
  type = map(string)
}

variable "VM_NAMES" {
  type = list(string)
}