# Create a Resource Group
resource "azurerm_resource_group" "tfdemo" {
  name     = "${var.prefix}-rg"
  location = var.region

  tags = {
    Site        = "${var.prefix}.mygrp.local"
    Customer    = var.customer
    Environment = var.environment
  }
}

