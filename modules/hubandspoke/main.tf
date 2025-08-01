provider "azurerm" {
  features        = {}
  subscription_id = var.subscription_id
}
# Create Network RG in Connectivity, Managemnet and AVD MG
# 1. Resource Group in ims-prd-connectivity (Connectivity subscription) 
resource "azurerm_resource_group" "conn" {
  provider = azurerm.ims-prd-connectivity
  name     = "ims-prd-conn-ne-rg-network"
  location = var.location
  tags = {
    Name        = "ims-prd-conn-ne-rg-network"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
  }
# 2. Resource Groups in ims-prd-management (Management subscription)
resource "azurerm_resource_group" "mgmt" {
  provider = azurerm.ims-prd-management
  name     = "ims-prd-mgmt-ne-rg-network"
  location = var.location
  
  tags = {
    Name        = "ims-prd-mgmt-ne-rg-network"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}
# 3. Resource Groups for ims-prd-avd (avd subscription)
resource "azurerm_resource_group" "avd" {
  provider = azurerm.ims-prd-avd
  name     = "ims-prd-avd-ne-rg-network"
  location = var.location
  
  tags = {
    Name        = "ims-prd-avd-ne-rg-network"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}
# Create Additional RG's in Management MG
# 1. Create defender RG in Management MG
resource "azurerm_resource_group" "mgmtdef" {
  provider = azurerm.ims-prd-management
  name     = "ims-prd-mgmt-ne-rg-defender"
  location = var.location
 
  tags = {
    Name        = "ims-prd-mgmt-ne-rg-defender"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}
# 2. Create Key Vault RG in Management MG
resource "azurerm_resource_group" "mgmtkv" {
  provider = azurerm.ims-prd-management
  name     = "ims-prd-mgmt-ne-rg-keyvault"
  location = var.location
  
  tags = {
    Name        = "ims-prd-mgmt-ne-rg-keyvault"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}
# 3. Create log-security RG in Management MG
resource "azurerm_resource_group" "mgmtlsec" {
  provider = azurerm.ims-prd-management
  name     = "ims-prd-mgmt-ne-rg-log-security"
  location = var.location
  
  tags = {
    Name        = "ims-prd-mgmt-ne-rg-log-security"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}
# 4. Create log-system RG in Management MG
resource "azurerm_resource_group" "mgmtlsys" {
  provider = azurerm.ims-prd-management
  name     = "ims-prd-mgmt-ne-rg-log-system"
  location = var.location

  tags = {
    Name        = "ims-prd-mgmt-ne-rg-log-system"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}
# 5. Create Purview RG in Management MG
resource "azurerm_resource_group" "mgmtpur" {
  provider = azurerm.ims-prd-management
  name     = "ims-prd-mgmt-ne-rg-purview"
  location = var.location
  
  tags = {
    Name        = "ims-prd-mgmt-ne-rg-purview"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}
# 6. Create storage RG in Management MG
resource "azurerm_resource_group" "mgmtstr" {
  provider = azurerm.ims-prd-management
  name     = "ims-prd-mgmt-ne-rg-storage"
  location = var.location
  
  tags = {
    Name        = "ims-prd-mgmt-ne-rg-storage"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}
# Create Additional RG's in AVD MG
# 1. Create Pool RG in AVD MG
resource "azurerm_resource_group" "avdpool" {
  provider = azurerm.ims-prd-avd
  name     = "ims-prd-avd-ne-rg-pool"
  location = var.location
  
  tags = {
    Name        = "ims-prd-avd-ne-rg-pool"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}
# 2. Create Personal RG in AVD MG
resource "azurerm_resource_group" "avdpsnl" {
  provider = azurerm.ims-prd-avd
  name     = "ims-prd-avd-ne-rg-psnl"
  location = var.location
  
  tags = {
    Name        = "ims-prd-avd-ne-rg-psnl"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}
####################################################################
# 1- Create "ims-prd-conn-ne-vnet-hub-01" connectivity-hub-vnet
####################################################################
resource "azurerm_virtual_network" "hubvnet" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = azurerm_resource_group.conn.name
  name                = "ims-prd-conn-ne-vnet-hub-01"
  location            = var.location
  address_space       = ["192.168.0.0/22"]

  encryption {
    enforcement = "AllowUnencrypted" 
  }

  depends_on = [
    azurerm_resource_group.ims-prd-conn-ne-rg-network
  ]

  tags = {
    Name        = "ims-prd-conn-ne-vnet-hub-01"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}

################################################################
# Create subnets
################################################################
# 1. Create "AzureFirewallSubnet" subnet for Firewall traffic at hub vNet
resource "azurerm_subnet" "AzureFirewallSubnet" {
  provider             = azurerm.ims-prd-connectivity
  resource_group_name  = azurerm_resource_group.conn.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  name                 = "AzureFirewallSubnet"
  address_prefixes     = ["192.168.0.64/26"]

  depends_on = [
    azurerm_virtual_network.ims-prd-conn-ne-vnet-hub-01
    ]
 }
