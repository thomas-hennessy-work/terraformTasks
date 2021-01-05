provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "NetflixRG" {
  name     = "Netflix-Resources"
  location = "France Central"
}

variable "location" {
  description = "availability zones for netflix"
  default = {
    1 = "France Central"
    2 = "Australia Central"
    3 = "Japan East"
  }
}

variable "scaleOutTime" {
    description = "the time in each region the scale set should scale out"
    default = {
    1 = "PT10M"
    2 = "PT9M"
    3 = "PT2M30"
    }
}

variable "scaleInTime" {
    description = "the time in each region the scale set should scale in"
    default = {
    1 = "PT15M"
    2 = "PT17M"
    3 = "PT10M30"
    }
}

module "Netflix_Scale_Set" {
  for_each = var.location

  source            = "./ScaleSet"
  region            = each.value
  key = each.key
  ResourceGroupName = azurerm_resource_group.NetflixRG.name
}

module "Netflix_Monitor" {
    for_each = var.location

    source = "./ScalingMonitor"
    region = each.value
    
}