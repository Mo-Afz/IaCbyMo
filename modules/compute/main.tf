resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  instances           = var.instance_count

  admin_username      = var.admin_username
  disable_password_authentication = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

os_disk {
  caching              = "ReadWrite"
  storage_account_type = var.enable_premium ? "Premium_LRS" : "Standard_LRS"
}

  admin_ssh_key {
  username   = var.admin_username
  public_key = var.ssh_public_key
}

  network_interface {
    name    = "${var.vmss_name}-nic"
    primary = true

    ip_configuration {
      name      = "${var.vmss_name}-ipconfig"
      subnet_id = var.subnet_id
    }
  }

  upgrade_mode = "Manual"

  zones = ["1", "2", "3"]

  depends_on = [var.subnet_id]
}