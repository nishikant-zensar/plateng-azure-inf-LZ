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
# Hub VNet
resource "azurerm_virtual_network" "hubvnet" {
  name                = "ims-prod-connectivity-neu-vnet-01"
  address_space       = ["192.168.0.0/22"]
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  provider = azurerm.hubsubscription
}

# Hub Subnet
resource "azurerm_subnet" "hub_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub-rg.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  address_prefixes     = ["192.168.0.0/26"]
  provider = azurerm.hubsubscription
}
