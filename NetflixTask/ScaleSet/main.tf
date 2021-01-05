provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "NetflixRG" {
  name     = "Netflix-Resources"
  location = var.region
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

resource "azurerm_network_security_group" "NFSecurityGroup" {
  name                = "NetflixSecurityGroup"
  location            = azurerm_resource_group.NetflixRG.location
  resource_group_name = azurerm_resource_group.NetflixRG.name

  security_rule {
    name                       = "allowSSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
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
    network_security_group_id = azurerm_network_security_group.NFSecurityGroup.id

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.NVNSubnet.id

      public_ip_address {
        name = "pubIP"
      }
    }
  }
}