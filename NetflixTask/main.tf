provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "NetflixRG" {
  name     = "Netflix-Resources"
  location = "UK South"
}