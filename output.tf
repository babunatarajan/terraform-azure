output "customer" {
  value = var.customer
}
output "environment" {
  value = var.environment 
}
output "prefix" {
  value = var.prefix
}
output "location" {
  value = azurerm_resource_group.tfdemo.location
}
output "static_public_ip" {
  value = azurerm_public_ip.external.ip_address
}
output "loadbalancer_endpoint" {
  value = azurerm_public_ip.external.domain_name_label
}
output "mysql_fqdn" {
  value = azurerm_mysql_server.tfdemo_mysql.fqdn
}
