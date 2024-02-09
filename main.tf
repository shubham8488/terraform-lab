resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.rg_location
}

resource "azurerm_virtual_network" "my_vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.address_space
  location            = azurerm_resource_group.this.location
}

resource "azurerm_subnet" "my_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_public_ip" "my_public_ip" {
  name                = format("%s_%s", var.vm_name, "public_ip")
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Dynamic"
  domain_name_label="jumpbox01"
}

resource "azurerm_network_interface" "my_nic" {
  name                = format("%s_%s", var.vm_name, "nic")
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = format("%s_%s", var.vm_name, "ip_configuration")
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_public_ip.id
  }
}

resource "azurerm_network_security_group" "my_nsg" {
  name                = format("%s_%s", var.vm_name, "nsg")
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = format("%s_%s", var.vm_name, "nsg_ssh_rule")
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "my_nsg_association" {
  network_interface_id      = azurerm_network_interface.my_nic.id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}

# resource "tls_private_key" "ssh_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096

# }




data "azurerm_image" "custom" {
  name                = var.custom_image_name
  resource_group_name = var.custom_image_resource_group_name
}

resource "azurerm_virtual_machine" "example" {
  name                  = var.vm_name
  location              = azurerm_resource_group.this.location
  resource_group_name   =  azurerm_resource_group.this.name
  network_interface_ids = [azurerm_network_interface.my_nic.id]
  vm_size               = "Standard_DS1_v2"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  storage_image_reference {
    id = data.azurerm_image.custom.id
  }

  storage_os_disk {
    name              = format("%s_%s", var.vm_name, "os_disk")
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }


    identity {
    type = "SystemAssigned"
  }

  os_profile {
    computer_name  = var.vm_name
    admin_username = var.vm_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data=data.azurerm_key_vault_secret.publicKey.value
      path="/home/${var.vm_username}/.ssh/authorized_keys"
      
    }
    
  }

}





# resource "azurerm_linux_virtual_machine" "my_jump_box" {
#   name                  = var.vm_name
#   location              = azurerm_resource_group.this.location
#   resource_group_name   = azurerm_resource_group.this.name
#   network_interface_ids = [azurerm_network_interface.my_nic.id]
#   size                  = "Standard_DS1_v2"

#   os_disk {
#     name                 = format("%s_%s", var.vm_name, "os_disk")
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }


#   identity {
#     type = "SystemAssigned"
#   }

#   computer_name                   = var.vm_name
#   admin_username                  = var.vm_username
#   disable_password_authentication = true

#   admin_ssh_key {
#     username   = var.vm_username
#     public_key = data.azurerm_key_vault_secret.publicKey.value
#   }
# }

