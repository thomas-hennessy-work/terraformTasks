provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "NetflixRG" {
  name     = "Netflix-Resources"
  location = "France Central"
}

resource "azurerm_virtual_network" "NetflixVN" {
  name                = "Netflix-Vertual-Network"
  resource_group_name = azurerm_resource_group.NetflixRG.name
  location            = azurerm_resource_group.NetflixRG.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "NVNSubnet" {
  name                 = "Netflix-Subnet"
  resource_group_name  = azurerm_resource_group.NetflixRG.name
  virtual_network_name = azurerm_virtual_network.NetflixVN.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "NetflixVMSS" {
  name                = "Netflix-Scale-Set"
  resource_group_name = azurerm_resource_group.NetflixRG.name
  location            = azurerm_resource_group.NetflixRG.location
  sku                 = "Standard_F1"
  instances           = 3
  admin_username      = "tom"

  admin_ssh_key {
    username   = "tom"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "Network-Interface"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.NVNSubnet.id
    }
  }
}