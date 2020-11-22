provider "azurerm" {
    skip_provider_registration = false
    features {}
}

terraform {
    backend "azurerm" {}
}

resource "azurerm_resource_group" "sp2016rg" {
    name     = "sp2016-vera"
    location = "northeurope"
}
