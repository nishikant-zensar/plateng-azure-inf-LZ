provider "azurerm" {
  features        = {}
  subscription_id = var.subscription_id
}

provider "azurerm" {
  alias           = "sub1"
  subscription_id = var.sub1_subscription_id
  features        = {}
}

provider "azurerm" {
  alias           = "sub2"
  subscription_id = var.sub2_subscription_id
  features        = {}
}
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
# Hub Resource Group Definition
resource "azurerm_resource_group" "hub-rg" {
  name     = "ims-prod-connectivity-neu-rg-network"
  location = var.location
  provider = azurerm.hubsubscription
}
