output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}
output "public_ip" {
  value = azurerm_public_ip.publicip.ip_address
}