# Create an Ubuntu Virtual Machine with key based access and run a script on boot; use a Standard SSD
resource "azurerm_virtual_machine" "tfdemo" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.tfdemo.location
  resource_group_name   = azurerm_resource_group.tfdemo.name
  network_interface_ids = [azurerm_network_interface.tfdemo.id]
  vm_size               = "Basic_A0"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = var.prefix
    admin_username = "ubuntu"
    custom_data    = data.template_file.init_script.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = file("~/.ssh/${var.prefix}.pub")
    }
  }

  tags = {
    Site        = "${var.prefix}.mygrp.local"
    Customer    = var.customer
    Environment = var.environment
  }
}
