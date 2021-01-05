resource "azurerm_virtual_network" "NetflixVN" {
  name                = "Netflix-Vertual-Network${var.key}"
  resource_group_name = var.ResourceGroupName
  location            = var.region
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "NVNSubnet" {
  name                 = "Netflix-Subnet${var.key}"
  resource_group_name  = var.ResourceGroupName
  virtual_network_name = azurerm_virtual_network.NetflixVN.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "NFSecurityGroup" {
  name                = "NetflixSecurityGroup${var.key}"
  location            = var.region
  resource_group_name = var.ResourceGroupName

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
}

resource "azurerm_linux_virtual_machine_scale_set" "NetflixVMSS" {
  name                = "Netflix-Scale-Set${var.key}"
  resource_group_name = var.ResourceGroupName
  location            = var.region
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
    name                      = "Network-Interface${var.key}"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.NFSecurityGroup.id

    ip_configuration {
      name      = "internal${var.key}"
      primary   = true
      subnet_id = azurerm_subnet.NVNSubnet.id

      public_ip_address {
        name = "pubIP"
      }
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "NetflixSSMonitor" {
  name                = "ScaleSetMonitor${var.key}"
  resource_group_name = var.ResourceGroupName
  location            = var.region
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.NetflixVMSS.id

  profile {
    name = "Active"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.NetflixVMSS.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.NetflixVMSS.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    recurrence {
      timezone  = var.timezone
      days      = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
      hours     = [var.active_hour]
      minutes   = [var.active_min]
    }
  }

  profile {
    name = "Inactive"

    capacity {
      default = 0
      minimum = 0
      maximum = 0
    }

    # rule {
    #   metric_trigger {
    #     metric_name        = "Percentage CPU"
    #     metric_resource_id = azurerm_virtual_machine_scale_set.example.id
    #     time_grain         = "PT1M"
    #     statistic          = "Average"
    #     time_window        = "PT5M"
    #     time_aggregation   = "Average"
    #     operator           = "GreaterThan"
    #     threshold          = 90
    #   }

    #   scale_action {
    #     direction = "Increase"
    #     type      = "ChangeCount"
    #     value     = "2"
    #     cooldown  = "PT1M"
    #   }
    # }

    recurrence {
      timezone  = var.timezone
      days      = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
      hours     = [var.inactive_hour]
      minutes   = [var.inactive_min]
    }
  }
}