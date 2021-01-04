provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "terraform_example" {
  name = "terraform_example_group"
  location = "UK South"
}
