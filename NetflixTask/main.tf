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
    2 = "West India"
    3 = "Japan East"
  }
}

module "Netflix_Scale_Set"{
  for_each = var.location

  source = "./ScaleSet"
  region = each.value
  ResourceGroupName = azurerm_resource_group.NetflixRG.name
}