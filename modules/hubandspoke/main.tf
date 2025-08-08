terraform {
  backend "azurerm" {
    resource_group_name  = "ims-prd-lz-ne-rg-terraformstate"
    storage_account_name = "imslandingznstr"
    container_name       = "tfstate"
    key                  = "hubspoke.terraform.tfstate" # Path to the state file in the container
    use_oidc_auth        = true
    use_azuread_auth     = true
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"  
}

provider "azurerm" {
  features {}
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
# Create "ims-prd-conn-ne-vnet-hub-01" connectivity-hub-vnet
####################################################################
resource "azurerm_virtual_network" "hubvnet" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = azurerm_resource_group.conn.name
  name                = "ims-prd-conn-ne-vnet-hub-01"
  location            = var.location
  address_space       = ["192.168.0.0/22"]
  dns_servers = ["192.168.0.132"]

  encryption {
    enforcement = "AllowUnencrypted" 
  }

  tags = {
    Name        = "ims-prd-conn-ne-vnet-hub-01"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }
}

################################################################
# Create subnets in hubvnet
################################################################
# 1. Create "AzureFirewallSubnet" subnet for Firewall traffic at hub vNet
resource "azurerm_subnet" "AzureFirewallSubnet" {
  provider             = azurerm.ims-prd-connectivity
  resource_group_name  = azurerm_resource_group.conn.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  name                 = "AzureFirewallSubnet"
  address_prefixes     = ["192.168.0.64/26"]
}

 # 2. Create "AzureFirewallManagementSubnet" subnet for Firewall Management traffic at hub vNet
resource "azurerm_subnet" "AzureFirewallManagementSubnet" {
  provider             = azurerm.ims-prd-connectivity
  resource_group_name  = azurerm_resource_group.conn.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  name                 = "AzureFirewallManagementSubnet"
  address_prefixes     = ["192.168.1.64/26"]

}
# 3. Create "GatewaySubnet" subnet for Gateway traffic at hub vNet
resource "azurerm_subnet" "GatewaySubnet" {
  provider             = azurerm.ims-prd-connectivity
  resource_group_name  = azurerm_resource_group.conn.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  name                 = "GatewaySubnet"
  address_prefixes     = ["192.168.0.0/26"]

  }
  # 4. Create "ims-prd-conn-ne-snet-dnsprin" subnet for inbound DNS private resolution traffic at hub vNet
resource "azurerm_subnet" "ims-prd-conn-ne-snet-dnsprin" {
  provider             = azurerm.ims-prd-connectivity
  resource_group_name  = azurerm_resource_group.conn.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  name                 = "ims-prd-conn-ne-snet-dnsprin"
  address_prefixes     = ["192.168.0.128/26"]

}
# 5. Create "ims-prd-conn-ne-snet-dnsprout" subnet for outbound DNS private resolution traffic at hub vNet
resource "azurerm_subnet" "ims-prd-conn-ne-snet-dnsprout" {
  provider             = azurerm.ims-prd-connectivity
  resource_group_name  = azurerm_resource_group.conn.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  name                 = "ims-prd-conn-ne-snet-dnsprout"
  address_prefixes     = ["192.168.0.192/26"]

}
# 6. Create "ims-prd-conn-ne-snet-pep" Private endpoint subnet at hub vNet
resource "azurerm_subnet" "ims-prd-conn-ne-snet-pep" {
  provider             = azurerm.ims-prd-connectivity
  resource_group_name  = azurerm_resource_group.conn.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  name                 = "ims-prd-conn-ne-snet-pep"
  address_prefixes     = ["192.168.1.0/26"]

}
####################################################
# Create "ims-prd-mgmt-ne-vnet-01" management vNet
####################################################
resource "azurerm_virtual_network" "mgmtvnet" {
  provider            = azurerm.ims-prd-management
  resource_group_name = azurerm_resource_group.mgmt.name
  name                = "ims-prd-mgmt-ne-vnet-01"
  location            = var.location
  address_space       = ["192.168.4.0/22"]

  encryption {
    enforcement = "AllowUnencrypted"
  }

  tags = {
    Name        = "ims-prd-mgmt-ne-vnet-01"
    Environment = "prd"
    DateCreated = "2025-08-01"
  }

}
################################################################
# Create Subnets in mgmt vnet
################################################################
# 1. Create "ims-prd-mgmt-ne-snet-security" subnet for mgmt security traffic at mgmt vNet
resource "azurerm_subnet" "ims-prd-mgmt-ne-snet-security" {
  provider             = azurerm.ims-prd-management
  resource_group_name  = azurerm_resource_group.mgmt.name
  virtual_network_name = azurerm_virtual_network.mgmtvnet.name
  name                 = "ims-prd-mgmt-ne-snet-security"
  address_prefixes     = ["192.168.4.0/26"]

}
# 2. Create "ims-prd-mgmt-ne-snet-system" subnet for mgmt system traffic at mgmt vNet
resource "azurerm_subnet" "ims-prd-mgmt-ne-snet-system" {
  provider             = azurerm.ims-prd-management
  resource_group_name  = azurerm_resource_group.mgmt.name
  virtual_network_name = azurerm_virtual_network.mgmtvnet.name
  name                 = "ims-prd-mgmt-ne-snet-system"
  address_prefixes     = ["192.168.4.64/26"]

}
# 3. Create "ims-prd-mgmt-ne-snet-keyvault" subnet for mgmt keyvault traffic at mgmt vNet
resource "azurerm_subnet" "ims-prd-mgmt-ne-snet-keyvault" {
  provider             = azurerm.ims-prd-management
  resource_group_name  = azurerm_resource_group.mgmt.name
  virtual_network_name = azurerm_virtual_network.mgmtvnet.name
  name                 = "ims-prd-mgmt-ne-snet-keyvault"
  address_prefixes     = ["192.168.4.128/26"]

}
# 4. Create "ims-prd-mgmt-ne-snet-pep" subnet for mgmt private endpoint traffic at mgmt vNet
resource "azurerm_subnet" "ims-prd-mgmt-ne-snet-pep" {
  provider             = azurerm.ims-prd-management
  resource_group_name  = azurerm_resource_group.mgmt.name
  virtual_network_name = azurerm_virtual_network.mgmtvnet.name
  name                 = "ims-prd-mgmt-ne-snet-pep"
  address_prefixes     = ["192.168.4.192/26"]

}

##################################################
# Create "ims-prd-avd-ne-vnet-01" avd vNet
##################################################
resource "azurerm_virtual_network" "avdvnet" {
  provider            = azurerm.ims-prd-avd
  resource_group_name = azurerm_resource_group.avd.name
  name                = "ims-prd-avd-ne-vnet-01"
  location            = var.location
  address_space       = ["192.168.8.0/22"]

  encryption {
    enforcement = "AllowUnencrypted"
  }

  tags = {
    Name          = "ims-prd-avd-ne-vnet-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

################################################################
# Create Subnets in avd vnet
################################################################
# 1. Create "ims-prd-avd-ne-snet-pool" subnet for avd pool traffic at avd vNet
resource "azurerm_subnet" "ims-prd-avd-ne-snet-pool" {
  provider             = azurerm.ims-prd-avd
  resource_group_name  = azurerm_resource_group.avd.name
  virtual_network_name = azurerm_virtual_network.avdvnet.name
  name                 = "ims-prd-avd-ne-snet-pool"
  address_prefixes     = ["192.168.8.0/24"]

}

# 2. Create "ims-prd-avd-ne-snet-personal" subnet for avd personal traffic at avd vNet
resource "azurerm_subnet" "ims-prd-avd-ne-snet-personal" {
  provider             = azurerm.ims-prd-avd
  resource_group_name  = azurerm_resource_group.avd.name
  virtual_network_name = azurerm_virtual_network.avdvnet.name
  name                 = "ims-prd-avd-ne-snet-personal"
  address_prefixes     = ["192.168.9.0/24"]

}

# 3. Create "ims-prd-avd-ne-snet-pep" subnet for avd private endpoint traffic at avd vNet
resource "azurerm_subnet" "ims-prd-avd-ne-snet-pep" {
  provider             = azurerm.ims-prd-avd
  resource_group_name  = azurerm_resource_group.avd.name
  virtual_network_name = azurerm_virtual_network.avdvnet.name
  name                 = "ims-prd-avd-ne-snet-pep"
  address_prefixes     = ["192.168.11.128/26"]

}

# 4. Create "ims-prd-avd-ne-snet-mgmt" subnet for avd management traffic at avd vNet
resource "azurerm_subnet" "ims-prd-avd-ne-snet-mgmt" {
  provider             = azurerm.ims-prd-avd
  resource_group_name  = azurerm_resource_group.avd.name
  virtual_network_name = azurerm_virtual_network.avdvnet.name
  name                 = "ims-prd-avd-ne-snet-mgmt"
  address_prefixes     = ["192.168.10.0/24"]

}
################################################################
# Peering Between vNets
################################################################
# Task 1: Peering between Hub and Mgmt vNet
resource "azurerm_virtual_network_peering" "hub_to_mgmt" {
  name                      = "ims-prd-conn-ne-vnet-hub-01-TO-ims-prd-mgmt-ne-vnet-01"
  resource_group_name       = "ims-prd-conn-ne-rg-network"
  virtual_network_name      = "ims-prd-conn-ne-vnet-hub-01"
  remote_virtual_network_id = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-mgmt-ne-vnet-01"
  provider                  = azurerm.ims-prd-connectivity

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

}

# Task 2: Peering between Hub and AVD vNet
resource "azurerm_virtual_network_peering" "hub_to_avd" {
  name                      = "ims-prd-conn-ne-vnet-hub-01-TO-ims-prd-avd-ne-vnet-01"
  resource_group_name       = "ims-prd-conn-ne-rg-network"
  virtual_network_name      = "ims-prd-conn-ne-vnet-hub-01"
  remote_virtual_network_id = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-avd-ne-vnet-01"
  provider                  = azurerm.ims-prd-connectivity

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

}

# Task 3: Peering between Mgmt and Hub vNet
resource "azurerm_virtual_network_peering" "mgmt_to_hub" {
  name                      = "ims-prd-mgmt-ne-vnet-01-TO-ims-prd-conn-ne-vnet-hub-01"
  resource_group_name       = "ims-prd-mgmt-ne-rg-network"
  virtual_network_name      = "ims-prd-mgmt-ne-vnet-01"
  remote_virtual_network_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01"
  provider                  = azurerm.ims-prd-management

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

}

 Task 4: Peering between Avd and Hub vNet
resource "azurerm_virtual_network_peering" "avd_to_hub" {
  name                      = "ims-prd-avd-ne-vnet-01-TO-ims-prd-conn-ne-vnet-hub-01"
  resource_group_name       = "ims-prd-avd-ne-rg-network"
  virtual_network_name      = "ims-prd-avd-ne-vnet-01"
  remote_virtual_network_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01"
  provider                  = azurerm.ims-prd-avd

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

}