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
    1 = ["France Central", "GMT Standard Time", 10, 0, 15, 0]
    2 = ["Australia Central", "GMT Standard Time", 9, 0, 17, 0]
    3 = ["Japan East", "GMT Standard Time", 14, 30, 20, 30]
  }
}

module "Netflix_Scale_Set" {
  for_each = var.location

  source            = "./ScaleSet"
  region            = element(each.value,0)
  key = each.key
  ResourceGroupName = azurerm_resource_group.NetflixRG.name

  timezone = element(each.value,1)
  active_hour = element(each.value,2)
  active_min = element(each.value,3)
  inactive_hour = element(each.value,4)
  inactive_min = element(each.value,5)
}