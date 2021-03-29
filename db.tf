# Create MySQL DB
resource "azurerm_mysql_server" "tfdemo_mysql" {
  name                = "tfdemo-mysqlserver"
  location            = var.region
  resource_group_name = azurerm_resource_group.tfdemo.name

  administrator_login          = "mysqadminun"
  administrator_login_password = "H@Sh1C0rP3!"

  sku_name   = "B_Gen5_1"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false 
# Private access only possible when choosing General Purpose and above instance types.
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

# Update the Charset to utf8
resource "azurerm_mysql_database" "tfdemo_mysql_charset" {
  name                = "tfdemo_db"
  resource_group_name = azurerm_resource_group.tfdemo.name
  server_name         = azurerm_mysql_server.tfdemo_mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# Associate with internal subnet, the following can enabled when choosing General Purpose and above instance types.
# resource "azurerm_mysql_virtual_network_rule" "tfdemo_mysql_vnet_rule" {
#  name                = "mysql-vnet-rule"
#  resource_group_name = azurerm_resource_group.tfdemo.name
#  server_name         = azurerm_mysql_server.tfdemo_mysql.name
#  subnet_id           = azurerm_subnet.internal.id
#}
