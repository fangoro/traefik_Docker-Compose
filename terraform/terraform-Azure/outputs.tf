output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}

output "ssh_connection_command" {
  value = "ssh ${azurerm_linux_virtual_machine.main.admin_username}@${azurerm_public_ip.main.ip_address}"
}


