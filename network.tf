# Create a Virtual Network
resource "azurerm_virtual_network" "tfdemo" {
  name                = "${var.prefix}-net"
  address_space       = ["10.0.110.0/25"]
  location            = azurerm_resource_group.tfdemo.location
  resource_group_name = azurerm_resource_group.tfdemo.name

  tags = {
    Site        = "${var.prefix}.mygrp.local"
    Customer    = var.customer
    Environment = var.environment
  }
}

# Add a Subnet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.tfdemo.name
  virtual_network_name = azurerm_virtual_network.tfdemo.name
  address_prefixes     = ["10.0.110.0/27"]
}


# Create a Network Security Group and allow inbound port(s)
resource "azurerm_network_security_group" "tfdemo" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.tfdemo.location
  resource_group_name = azurerm_resource_group.tfdemo.name
  tags = {
    Site        = "${var.prefix}.mygrp.local"
    Customer    = var.customer
    Environment = var.environment
  }
}

resource "azurerm_network_security_rule" "tfdemo_int_http" {
  name                        = "HTTP"
  priority                    = 1005
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfdemo.name
  network_security_group_name = azurerm_network_security_group.tfdemo.name
}

resource "azurerm_network_security_rule" "tfdemo_int_ssh" {
  name                        = "SSH"
  priority                    = 1006
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfdemo.name
  network_security_group_name = azurerm_network_security_group.tfdemo.name
}

resource "azurerm_network_security_rule" "tfdemo_int_https" {
  name                        = "HTTPs"
  priority                    = 1007
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfdemo.name
  network_security_group_name = azurerm_network_security_group.tfdemo.name
}

# Create a Network Interface with a Dynamic Private IP
resource "azurerm_network_interface" "tfdemo" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.tfdemo.location
  resource_group_name = azurerm_resource_group.tfdemo.name

  ip_configuration {
    name                          = "${var.prefix}-nic_conf"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    #    public_ip_address_id          = azurerm_public_ip.external.id
  }

  tags = {
    Site        = "${var.prefix}.mygrp.local"
    Customer    = var.customer
    Environment = var.environment
  }
}


# Associate a Security Group on Network Interface attached in the VM
resource "azurerm_network_interface_security_group_association" "tfdemo" {
  network_interface_id      = azurerm_network_interface.tfdemo.id
  network_security_group_id = azurerm_network_security_group.tfdemo.id
}

