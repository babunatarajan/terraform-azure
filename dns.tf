# Create a DNS Zone
resource "azurerm_dns_zone" "tfdemo" {
  name                = "${var.prefix}.mygrp.local"
  resource_group_name = azurerm_resource_group.tfdemo.name

  tags = {
    Site        = "${var.prefix}.mygrp.local"
    Customer    = var.customer
    Environment = var.environment
  }
}
