provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "terraform_example" {
  name = "terraform_rg"
  location = "UK South"
}

resource "azurerm_virtual_network" "terraform_example"{
  name = "example-network"
  #ip address of the az virtual network
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.terraform_example.location
  resource_group_name = azurerm_resource_group.terraform_example.name
}

resource "azurerm_subnet" "terraform_example"{
  name = "internal"
  resource_group_name = azurerm_resource_group.terraform_example.name
  virtual_network_name = azurerm_virtual_network.terraform_example.name
  #Do extra research on address prefixes
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "terraform_example" {
  name                = "PublicIp1"
  resource_group_name = azurerm_resource_group.terraform_example.name
  location            = azurerm_resource_group.terraform_example.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "terraform_example"{
  name = "example-nint"
  location = azurerm_resource_group.terraform_example.location
  resource_group_name = azurerm_resource_group.terraform_example.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.terraform_example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.terraform_example.id
  }
}

resource "azurerm_network_security_group" "terraform_example"{
  name = "terraform_nsg"
  location = azurerm_resource_group.terraform_example.location
  resource_group_name = azurerm_resource_group.terraform_example.name
}

resource "azurerm_network_security_rule" "allow_ssh"{
  name = "allowSSH"
  priority = 300
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.terraform_example.name
  network_security_group_name = azurerm_network_security_group.terraform_example.name
}

resource "azurerm_subnet_network_security_group_association" "terraform_example"{
  subnet_id = azurerm_subnet.terraform_example.id
  network_security_group_id = azurerm_network_security_group.terraform_example.id
}

resource "azurerm_linux_virtual_machine" "terraform_example"{
  name = var.name
  resource_group_name = azurerm_resource_group.terraform_example.name
  location = azurerm_resource_group.terraform_example.location
  size = var.size
  admin_username = var.adminuser
  network_interface_ids = [
    azurerm_network_interface.terraform_example.id,
  ]

  admin_ssh_key {
    username   = var.adminuser
    public_key = file("/home/tom/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
