output "public_ips" {
  value = azurerm_public_ip.my_pip[*].ip_address
}

/*
output "VM_names" {
  value = azurerm_linux_virtual_machine.my_VM[*].name
}
*/

output "resource_group_name" {
  value = azurerm_resource_group.my_rg.name
}

output "instance_type" {
  value = var.instance_type["Testing"]
}

output "load_balancer_ip" {
  value = azurerm_public_ip.my_pip.ip_address
}
/*
output "privateIP" {
  value = azurerm_linux_virtual_machine.my_VM[*].private_ip_addresses[0]
}
*/

/*
output "VM_names" {
  value = azurerm_windows_virtual_machine.Windows_VM[*].name
}
*/
