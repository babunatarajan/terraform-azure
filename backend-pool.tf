# Create a backend address pool for Load Balancer
resource "azurerm_lb_backend_address_pool" "tfdemo" {
  loadbalancer_id = azurerm_lb.tfdemo.id
  name            = "${var.prefix}-lb-addr-pool"
}

# Attach the VM ip to the backend address pool
resource "azurerm_lb_backend_address_pool_address" "tfdemo-addr-pool" {
  name                    = "${var.prefix}-addr-pool-addr"
  backend_address_pool_id = azurerm_lb_backend_address_pool.tfdemo.id
  virtual_network_id      = azurerm_virtual_network.tfdemo.id
  ip_address              = azurerm_network_interface.tfdemo.private_ip_address
}

# Allocate a Public IP
resource "azurerm_public_ip" "external" {
  name                = "external"
  location            = azurerm_resource_group.tfdemo.location
  resource_group_name = azurerm_resource_group.tfdemo.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.prefix}-mygrp-local"

  tags = {
    Site        = "${var.prefix}.mygrp.local"
    Customer    = var.customer
    Environment = var.environment
  }
}

# Create a Load Balancer (TCP and non-HTTP(S), you can configure Certbot/LetsEncrypt or own CA Cert on Linux Instances, this is to reduce the cost for not using the Application Gateway (HTTPs)
# Refer (https://docs.microsoft.com/en-us/azure/architecture/guide/technology-choices/load-balancing-overview#decision-tree-for-load-balancing-in-azure)
# Azure Load Balancer is a high-performance, ultra low-latency Layer 4 load-balancing service (inbound and outbound) for all UDP and TCP protocols. It is built to handle millions of requests per second while ensuring your solution is highly available. Azure Load Balancer is zone-redundant, ensuring high availability across Availability Zones.

resource "azurerm_lb" "tfdemo" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.tfdemo.location
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.tfdemo.name

  frontend_ip_configuration {
    name                 = "LBExternalAddress"
    public_ip_address_id = azurerm_public_ip.external.id
  }

  tags = {
    Site        = "${var.prefix}.mygrp.local"
    Customer    = var.customer
    Environment = var.environment
  }
}


# Create a LB Listener rule
resource "azurerm_lb_rule" "tfdemo_http" {
  resource_group_name            = azurerm_resource_group.tfdemo.name
  loadbalancer_id                = azurerm_lb.tfdemo.id
  name                           = "${var.prefix}-Http-LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LBExternalAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.tfdemo.id
  probe_id                       = azurerm_lb_probe.tfdemo-probe-http.id
}

resource "azurerm_lb_rule" "tfdemo_ssh" {
  resource_group_name            = azurerm_resource_group.tfdemo.name
  loadbalancer_id                = azurerm_lb.tfdemo.id
  name                           = "${var.prefix}-Ssh-LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "LBExternalAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.tfdemo.id
  probe_id                       = azurerm_lb_probe.tfdemo-probe-ssh.id
}

resource "azurerm_lb_rule" "tfdemo_https" {
  resource_group_name            = azurerm_resource_group.tfdemo.name
  loadbalancer_id                = azurerm_lb.tfdemo.id
  name                           = "${var.prefix}-Https-LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "LBExternalAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.tfdemo.id
  probe_id                       = azurerm_lb_probe.tfdemo-probe-http.id
}

# Create a Network Security Group for Load Balancer 
resource "azurerm_network_security_group" "tfdemo-lb-sg" {
  name                = "${var.prefix}-lb-sg"
  location            = azurerm_resource_group.tfdemo.location
  resource_group_name = azurerm_resource_group.tfdemo.name

  tags = {
    Site        = "${var.prefix}.mygrp.local"
    Customer    = var.customer
    Environment = var.environment
  }
}

# Allow inbound ports for Load Balancer
resource "azurerm_network_security_rule" "tfdemo-lb-sg-ssh" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfdemo.name
  network_security_group_name = azurerm_network_security_group.tfdemo-lb-sg.name
}
resource "azurerm_network_security_rule" "tfdemo-lb-sg-http" {
  name                        = "HTTP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfdemo.name
  network_security_group_name = azurerm_network_security_group.tfdemo-lb-sg.name
}

resource "azurerm_network_security_rule" "tfdemo-lb-sg-https" {
  name                        = "HTTPs"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfdemo.name
  network_security_group_name = azurerm_network_security_group.tfdemo-lb-sg.name
}
resource "azurerm_lb_probe" "tfdemo-probe-ssh" {
  resource_group_name = azurerm_resource_group.tfdemo.name
  loadbalancer_id     = azurerm_lb.tfdemo.id
  name                = "ssh-running-probe"
  port                = 22
}
resource "azurerm_lb_probe" "tfdemo-probe-http" {
  resource_group_name = azurerm_resource_group.tfdemo.name
  loadbalancer_id     = azurerm_lb.tfdemo.id
  name                = "http-running-probe"
  port                = 80
}
resource "azurerm_lb_probe" "tfdemo-probe-https" {
  resource_group_name = azurerm_resource_group.tfdemo.name
  loadbalancer_id     = azurerm_lb.tfdemo.id
  name                = "https-running-probe"
  port                = 443
}
