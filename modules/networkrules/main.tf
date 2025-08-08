###################
# Create nsg on hub vnet
###################
terraform {
  backend "azurerm" {
    resource_group_name  = "ims-prd-lz-ne-rg-terraformstate"
    storage_account_name = "imslandingznstr"
    container_name       = "tfstate"
    key                  = "netrules.terraform.tfstate" # Path to the state file in the container
    use_oidc_auth        = true
    use_azuread_auth     = true
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.36"
    }
  }
  required_version = ">= 1.9, < 2.0"  
}
#1. Create a nsg to associate with "ims-prd-conn-ne-snet-dnsprin" subnet in hub vNet 
  resource "azurerm_network_security_group" "ims-prd-conn-ne-nsg-dnsprin" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = "ims-prd-conn-ne-rg-network"
  name                = "ims-prd-conn-ne-nsg-dnsprin"
  location            = "northeurope"

  security_rule {
    direction                     = "Inbound"
    source_address_prefixes       = ["192.168.0.0/22", "192.168.4.0/22", "192.168.8.0/22"]
    source_port_range             = "*"
    destination_address_prefixes  = ["192.168.0.132"]
    destination_port_range        = "53"
    protocol                      = "Tcp"
    access                        = "Allow"
    priority                      = 3000
    name                          = "hub-AllowDNS-TCP-Inbound"
    description                   = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    direction                     = "Inbound"
    source_address_prefixes       = ["192.168.0.0/22", "192.168.4.0/22", "192.168.8.0/22"]
    source_port_range             = "*"
    destination_address_prefixes  = ["192.168.0.132"]
    destination_port_range        = "53"
    protocol                      = "Udp"
    access                        = "Allow"
    priority                      = 3001
    name                          = "hub-AllowDNS-UDP-Inbound"
    description                   = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    direction                     = "Inbound"
    source_address_prefix         = "*"
    source_port_range             = "*"
    destination_address_prefix    = "*"
    destination_port_range        = "*"
    protocol                      = "*"
    access                        = "Deny"
    priority                      = 4095
    name                          = "hub-DenyAnyToAnyInbound"
    description                   = "DenyAll"
  }

  security_rule {
    direction                     = "Outbound"
    source_address_prefixes       = ["192.168.0.132"]
    source_port_range             = "*"
    destination_address_prefixes  = ["192.168.0.192/26"]
    destination_port_range        = "53"
    protocol                      = "Tcp"
    access                        = "Allow"
    priority                      = 3000
    name                          = "hub-AllowDNS-TCP-Outbound"
    description                   = "Allow access to DNS Private Resolver Outbound EP"
  }

  security_rule {
    direction                     = "Outbound"
    source_address_prefixes       = ["192.168.0.132"]
    source_port_range             = "*"
    destination_address_prefixes  = ["192.168.0.192/26"]
    destination_port_range        = "53"
    protocol                      = "Udp"
    access                        = "Allow"
    priority                      = 3001
    name                          = "hub-AllowDNS-UDP-Outbound"
    description                   = "Allow access to DNS Private Resolver Outbound EP"
  }

  security_rule {
    direction                     = "Outbound"
    source_address_prefix         = "*"
    source_port_range             = "*"
    destination_address_prefix    = "*"
    destination_port_range        = "*"
    protocol                      = "*"
    access                        = "Deny"
    priority                      = 4095
    name                          = "hub-DenyAnyToAnyOutbound"
    description                   = "DenyAll"
  }

// depends_on = [
//   azurerm_resource_group.ims-prd-conn-ne-rg-network
// ]
    
    tags = {
      Name          = "ims-prd-conn-ne-nsg-dnsprin"
      Environment   = "prd"
      DateCreated   = "2025-08-01"
      }
  }

  # 2. Create a nsg to associate with "ims-prd-conn-ne-snet-dnsprout" subnet in hub vNet
  resource "azurerm_network_security_group" "ims-prd-conn-ne-nsg-dnsprout" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = "ims-prd-conn-ne-rg-network"
  name                = "ims-prd-conn-ne-nsg-dnsprout"
  location            = "northeurope"

  security_rule {
    direction                     = "Inbound"
    source_address_prefixes       = ["192.168.0.0/22", "192.168.4.0/22", "192.168.8.0/22"]
    source_port_range             = "*"
    destination_address_prefixes  = ["192.168.0.192/26"]
    destination_port_range        = "53"
    protocol                      = "Tcp"
    access                        = "Allow"
    priority                      = 3000
    name                          = "hub-AllowDNS-TCP-Inbound"
    description                   = "Allow DNS Private Resolver endpoint to receive queries"
    }

  security_rule {
    direction                     = "Inbound"
    source_address_prefixes       = ["192.168.0.0/22", "192.168.4.0/22", "192.168.8.0/22"]
    source_port_range             = "*"
    destination_address_prefixes  = ["192.168.0.192/26"]
    destination_port_range        = "53"
    protocol                      = "Udp"
    access                        = "Allow"
    priority                      = 3001
    name                          = "hub-AllowDNS-UDP-Inbound"
    description                   = "Allow DNS Private Resolver endpoint to receive queries"
    }

  security_rule {
    direction                     = "Inbound"
    source_address_prefix         = "*"
    source_port_range             = "*"
    destination_address_prefix    = "*"
    destination_port_range        = "*"
    protocol                      = "*"
    access                        = "Deny"
    priority                      = 4095
    name                          = "hub-DenyAnyToAnyInbound"
    description                   = "DenyAll"
    }

  security_rule {
    direction                     = "Outbound"
    source_address_prefixes       = ["192.168.0.192/26"]
    source_port_range             = "*"
    destination_address_prefix    = "*"
    destination_port_range        = "53"
    protocol                      = "Tcp"
    access                        = "Allow"
    priority                      = 3000
    name                          = "hub-AllowDNS-TCP-Outbound"
    description                   = "Allow access to DNS Private Resolver Outbound EP"
    }

  security_rule {
    direction                     = "Outbound"
    source_address_prefixes       = ["192.168.0.132"]
    source_port_range             = "*"
    destination_address_prefix    = "*"
    destination_port_range        = "53"
    protocol                      = "Udp"
    access                        = "Allow"
    priority                      = 3001
    name                          = "hub-AllowDNS-UDP-Outbound"
    description                   = "Allow access to DNS Private Resolver Outbound EP"
    }

  security_rule {
    direction                     = "Outbound"
    source_address_prefix         = "*"
    source_port_range             = "*"
    destination_address_prefix    = "*"
    destination_port_range        = "*"
    protocol                      = "*"
    access                        = "Deny"
    priority                      = 4095
    name                          = "hub-DenyAnyToAnyOutbound"
    description                   = "DenyAll"
    }

    # depends_on = [
    #   azurerm_resource_group.ims-prd-conn-ne-rg-network
    # ]

    tags = {
      Name          = "ims-prd-conn-ne-nsg-dnsprout"
      Environment   = "prd"
      DateCreated   = "2025-08-01"
      }
  }

#3. Create a nsg to associate with "ims-prd-conn-ne-snet-pep" subnet in hub vNet
  resource "azurerm_network_security_group" "ims-prd-conn-ne-nsg-pep" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = "ims-prd-conn-ne-rg-network"
  name                = "ims-prd-conn-ne-nsg-pep"
  location            = "northeurope"

  security_rule {
    direction                     = "Inbound"
    source_address_prefix         = "*"
    source_port_range             = "*"
    destination_address_prefix    = "*"
    destination_port_range        = "*"
    protocol                      = "*"
    access                        = "Deny"
    priority                      = 4095
    name                          = "hub-DenyAnyToAnyInbound"
    description                   = "DenyAll"
    }

  security_rule {
    direction                     = "Outbound"
    source_address_prefix         = "*"
    source_port_range             = "*"
    destination_address_prefix    = "*"
    destination_port_range        = "*"
    protocol                      = "*"
    access                        = "Deny"
    priority                      = 4095
    name                          = "hub-DenyAnyToAnyOutbound"
    description                   = "DenyAll"
    }

    security_rule {
    direction                     = "Outbound"
    source_address_prefix         = "192.168.1.0/26"
    source_port_range             = "*"
    destination_address_prefix    = "*"
    destination_port_range        = "53"
    protocol                      = "Tcp"
    access                        = "Allow"
    priority                      = 3000
    name                          = "hub-AllowDNS-TCP-Outbound"
    description                   = "Allow access to DNS Private Resolver Inbound EP"
    }

    security_rule {
    direction                     = "Outbound"
    source_address_prefix         = "192.168.1.0/26"
    source_port_range             = "*"
    destination_address_prefix    = "*"
    destination_port_range        = "53"
    protocol                      = "Udp"
    access                        = "Allow"
    priority                      = 3001
    name                          = "hub-AllowDNS-TCP-Outbound"
    description                   = "Allow access to DNS Private Resolver Inbound EP"
    }
    # depends_on = [
    #   azurerm_resource_group.ims-prd-conn-ne-rg-network
    # ]

    tags = {
      Name          = "ims-prd-conn-ne-nsg-pep"
      Environment   = "prd"
      DateCreated   = "2025-08-01"
      }
 }


###################
# Create UDR 
###################

provider "azurerm" {
  alias           = "ims-prd-connectivity"
  subscription_id = "ecd60543-12a0-4899-9e5f-21ec01592207"
  tenant_id       = "684d2402-0ea6-442d-9ad7-4ef26b925ec5"
  client_id       = "74925104-cd8b-47e5-b29a-83a75a2f4ca6"
  features {}
}

#1. Create a udr to associate with "GatewaySubnet" subnet in hub vNet
resource "azurerm_route_table" "ims-prd-conn-ne-rt-vpng" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = "ims-prd-conn-ne-rg-network"
  name                = "ims-prd-conn-ne-rt-vpng"
  location            = "northeurope"
  
  route {
    name                   = "ims-prd-conn-ne-udr-vnet-adv"
    address_prefix         = "192.168.8.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-conn-ne-udr-vnet-mgmt"
    address_prefix         = "192.168.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-conn-ne-udr-snet-dnsprin"
    address_prefix         = "192.168.0.128/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-conn-ne-udr-snet-dnsprout"
    address_prefix         = "192.168.0.192/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-conn-ne-udr-snet-hubpep"
    address_prefix         = "192.168.1.0/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  
  # depends_on = [
  #   azurerm_resource_group.ims-prd-conn-ne-rg-network
  # ]
  tags = {
    Name          = "ims-prd-conn-ne-rt-vpng"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

#2. Create a udr to associate with "ims-prd-conn-ne-snet-dnsprin" subnet subnet in hub vNet
resource "azurerm_route_table" "ims-prd-conn-ne-rt-dnsprin" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = "ims-prd-conn-ne-rg-network"
  name                = "ims-prd-conn-ne-rt-dnsprin"
  location            = "northeurope"
  
  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-conn-ne-udr-vnet-aws"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-conn-ne-udr-vnet-avd"
    address_prefix         = "192.168.8.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-conn-ne-udr-vnet-mgmt"
    address_prefix         = "192.168.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  
  # depends_on = [
  #   azurerm_resource_group.ims-prd-conn-ne-rg-network
  # ]

  tags = {
    Name          = "ims-prd-conn-ne-rt-dnsprin"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}


#3. Create a udr to associate with "ims-prd-conn-ne-snet-dnsprout" subnet subnet in hub vNet
resource "azurerm_route_table" "ims-prd-conn-ne-rt-dnsprout" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = "ims-prd-conn-ne-rg-network"
  name                = "ims-prd-conn-ne-rt-dnsprout"
  location            = "northeurope"
  
  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-conn-ne-udr-vnet-aws"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-conn-ne-udr-vnet-avd"
    address_prefix         = "192.168.8.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-conn-ne-udr-vnet-mgmt"
    address_prefix         = "192.168.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  # depends_on = [
  #   azurerm_resource_group.ims-prd-conn-ne-rg-network
  # ]
  
  tags = {
    Name          = "ims-prd-conn-ne-rt-dnsprout"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

###############################
# Create NSGs on mgmt vnet
###############################
#1. Create a nsg to associate with "ims-prd-mgmt-ne-snet-security" subnet in the mgmt vNet 
resource "azurerm_network_security_group" "ims-prd-mgmt-ne-nsg-security" {
  provider            = azurerm.ims-prd-management
  resource_group_name = "ims-prd-mgmt-ne-rg-network"
  name                = "ims-prd-mgmt-ne-nsg-security"
  location            = "northeurope"

  security_rule {
    name                       = "mgmt-DenyAnyToAnyInbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "mgmt-AllowDNS-TCP-Outbound"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.4.0/26"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "mgmt-AllowDNS-UDP-Outbound"
    priority                   = 3001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.4.0/26"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "mgmt-DenyAnyToAnyOutbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  tags = {
    name          = "ims-prd-mgmt-ne-nsg-security"
    environment   = "prd"
    function      = "nsg"
    data_creation = "2025-07-21"
  }

  # depends_on = [
  #   azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  # ]
}

#2. Create a nsg to associate with "ims-prd-mgmt-ne-snet-system" subnet in the mgmt vNet 
resource "azurerm_network_security_group" "ims-prd-mgmt-ne-nsg-system" {
  provider            = azurerm.ims-prd-management
  resource_group_name = "ims-prd-mgmt-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-mgmt-ne-nsg-system"

  security_rule {
    name                       = "mgmt-DenyAnyToAnyInbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "mgmt-AllowDNS-TCP-Outbound"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.4.64/26"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "mgmt-AllowDNS-UDP-Outbound"
    priority                   = 3001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.4.64/26"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "mgmt-DenyAnyToAnyOutbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  tags = {
    name          = "ims-prd-mgmt-ne-nsg-system"
    environment   = "prd"
    function      = "nsg"
    data_creation = "2025-07-21"
  }

  # depends_on = [
  #   azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  # ]
}

#3. Create a nsg to associate with "ims-prd-mgmt-ne-snet-keyvault" subnet in the mgmt vNet 
resource "azurerm_network_security_group" "ims-prd-mgmt-ne-nsg-keyvault" {
  provider            = azurerm.ims-prd-management
  resource_group_name = "ims-prd-mgmt-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-mgmt-ne-nsg-keyvault"

  security_rule {
    name                       = "mgmt-DenyAnyToAnyInbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "mgmt-AllowDNS-TCP-Outbound"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.4.128/26"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "mgmt-AllowDNS-UDP-Outbound"
    priority                   = 3001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.4.128/26"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "mgmt-DenyAnyToAnyOutbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  tags = {
    name          = "ims-prd-mgmt-ne-nsg-keyvault"
    environment   = "prd"
    function      = "nsg"
    data_creation = "2025-07-21"
  }
  #  depends_on = [
  #   azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  # ]
}

#4. Create a nsg to associate with "ims-prd-mgmt-ne-snet-pep" subnet in the mgmt vNet
resource "azurerm_network_security_group" "ims-prd-mgmt-ne-nsg-pep" {
  provider            = azurerm.ims-prd-management
  resource_group_name = "ims-prd-mgmt-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-mgmt-ne-nsg-pep"

  security_rule {
    name                       = "mgmt-DenyAnyToAnyInbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "mgmt-AllowDNS-TCP-Outbound"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.4.192/26"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "mgmt-AllowDNS-UDP-Outbound"
    priority                   = 3001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.4.192/26"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "mgmt-DenyAnyToAnyOutbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  tags = {
    name          = "ims-prd-mgmt-ne-nsg-pep"
    environment   = "prd"
    function      = "nsg"
    data_creation = "2025-07-21"
  }
  #  depends_on = [
  #   azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  # ]
}
###############################
# Create UDRs
###############################
#1. Create a udr to associate with "ims-prd-mgmt-ne-snet-keyvault" subnet in the mgmt vNet
resource "azurerm_route_table" "ims-prd-mgmt-ne-rt-keyvault" {
  provider            = azurerm.ims-prd-management
  resource_group_name = "ims-prd-mgmt-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-mgmt-ne-rt-keyvault"

  route {
    name                   = "defaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-mgmt-ne-udr-vnet-avd"
    address_prefix         = "192.168.8.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-mgmt-ne-udr-snet-dnsprin"
    address_prefix         = "192.168.0.128/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-mgmt-ne-udr-snet-vpng"
    address_prefix         = "192.168.0.0/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  tags = {
    name          = "ims-prd-mgmt-ne-rt-keyvault"
    environment   = "prd"
    function      = "route table"
    data_creation = "2025-07-21"
  }
  # depends_on = [
  #   azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  # ]
}

#2. Create a udr to associate with "ims-prd-mgmt-ne-snet-security" subnet in the mgmt vNet
resource "azurerm_route_table" "ims-prd-mgmt-ne-rt-security" {
  provider            = azurerm.ims-prd-management
  resource_group_name = "ims-prd-mgmt-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-mgmt-ne-rt-security"

  route {
    name                   = "defaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-mgmt-ne-udr-vnet-avd"
    address_prefix         = "192.168.8.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-mgmt-ne-udr-snet-dnsprin"
    address_prefix         = "192.168.0.128/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-mgmt-ne-udr-snet-vpng"
    address_prefix         = "192.168.0.0/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  tags = {
    name          = "ims-prd-mgmt-ne-rt-security"
    environment   = "prd"
    function      = "route table"
    data_creation = "2025-07-21"
  }
  # depends_on = [
  #   azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  # ]
}

#3. Create a udr to associate with "ims-prd-mgmt-ne-snet-system" subnet in the mgmt vNet
resource "azurerm_route_table" "ims-prd-mgmt-ne-rt-system" {
  provider            = azurerm.ims-prd-management
  resource_group_name = "ims-prd-mgmt-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-mgmt-ne-rt-system"

  route {
    name                   = "defaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-mgmt-ne-udr-vnet-avd"
    address_prefix         = "192.168.8.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-mgmt-ne-udr-snet-dnsprin"
    address_prefix         = "192.168.0.128/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-mgmt-ne-udr-snet-vpng"
    address_prefix         = "192.168.0.0/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  tags = {
    name          = "ims-prd-mgmt-ne-rt-system"
    environment   = "prd"
    function      = "route table"
    data_creation = "2025-07-21"
  }
  # depends_on = [
  #   azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  # ]
}

###############################
# Create NSGs on avd vnet
###############################
#1. Create a nsg to associate with "ims-prd-avd-ne-snet-pool" subnet in the avd vNet 
resource "azurerm_network_security_group" "ims-prd-avd-ne-nsg-pool" {
  provider            = azurerm.ims-prd-avd
  resource_group_name = "ims-prd-avd-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-avd-ne-nsg-pool"

  security_rule {
    name                       = "avd-DenyAnyToAnyInbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "avd-AllowDNS-TCP-Outbound"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.8.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "avd-AllowDNS-UDP-Outbound"
    priority                   = 3001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.8.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "avd-AllowZscaler-UDP-Outbound"
    priority                   = 3010
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.8.0/24"
    source_port_range          = "*"
    destination_address_prefixes = [
      "147.161.224.0/23", "170.85.58.0/23", "165.225.80.0/22", "147.161.166.0/23",
      "136.226.166.0/23", "136.226.168.0/23", "147.161.140.0/23", "147.161.142.0/23",
      "147.161.144.0/23", "136.226.190.0/23", "147.161.236.0/23", "165.225.196.0/23",
      "165.225.198.0/23", "170.85.84.0/23", "194.9.112.0/23", "194.9.106.0/23",
      "194.9.108.0/23", "194.9.110.0/23", "194.9.114.0/23"
    ]
    destination_port_ranges    = ["80", "443"]
    description                = "Allow AVD access to ZScaler for Internet Access"
  }

  security_rule {
    name                       = "avd-AllowZscaler-TCP-Outbound"
    priority                   = 3011
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.8.0/24"
    source_port_range          = "*"
    destination_address_prefixes = [
      "147.161.224.0/23", "170.85.58.0/23", "165.225.80.0/22", "147.161.166.0/23",
      "136.226.166.0/23", "136.226.168.0/23", "147.161.140.0/23", "147.161.142.0/23",
      "147.161.144.0/23", "136.226.190.0/23", "147.161.236.0/23", "165.225.196.0/23",
      "165.225.198.0/23", "170.85.84.0/23", "194.9.112.0/23", "194.9.106.0/23",
      "194.9.108.0/23", "194.9.110.0/23", "194.9.114.0/23"
    ]
    destination_port_ranges    = ["80", "443", "9400", "9480", "9443"]
    description                = "Allow AVD access to ZScaler for Internet Access"
  }

  security_rule {
    name                       = "avd-DenyAnyToAnyOutbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  tags = {
    name          = "ims-prd-avd-ne-nsg-pool"
    environment   = "prd"
    function      = "nsg"
    data_creation = "2025-07-21"
  }
  # depends_on = [
  #   azurerm_resource_group.ims-prd-avd-ne-rg-network
  # ]
}

#2. Create a nsg to associate with "ims-prd-avd-ne-snet-personal" subnet in the avd vNet
resource "azurerm_network_security_group" "ims-prd-avd-ne-nsg-personal" {
  provider            = azurerm.ims-prd-avd
  resource_group_name = "ims-prd-avd-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-avd-ne-nsg-personal"

  security_rule {
    name                       = "avd-DenyAnyToAnyInbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "avd-AllowDNS-TCP-Outbound"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.9.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "avd-AllowDNS-UDP-Outbound"
    priority                   = 3001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.9.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "avd-AllowZscaler-UDP-Outbound"
    priority                   = 3010
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.9.0/24"
    source_port_range          = "*"
    destination_address_prefixes = [
      "147.161.224.0/23", "170.85.58.0/23", "165.225.80.0/22", "147.161.166.0/23",
      "136.226.166.0/23", "136.226.168.0/23", "147.161.140.0/23", "147.161.142.0/23",
      "147.161.144.0/23", "136.226.190.0/23", "147.161.236.0/23", "165.225.196.0/23",
      "165.225.198.0/23", "170.85.84.0/23", "194.9.112.0/23", "194.9.106.0/23",
      "194.9.108.0/23", "194.9.110.0/23", "194.9.114.0/23"
    ]
    destination_port_ranges    = ["80", "443"]
    description                = "Allow AVD access to ZScaler for Internet Access"
  }

  security_rule {
    name                       = "avd-AllowZscaler-TCP-Outbound"
    priority                   = 3011
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.9.0/24"
    source_port_range          = "*"
    destination_address_prefixes = [
      "147.161.224.0/23", "170.85.58.0/23", "165.225.80.0/22", "147.161.166.0/23",
      "136.226.166.0/23", "136.226.168.0/23", "147.161.140.0/23", "147.161.142.0/23",
      "147.161.144.0/23", "136.226.190.0/23", "147.161.236.0/23", "165.225.196.0/23",
      "165.225.198.0/23", "170.85.84.0/23", "194.9.112.0/23", "194.9.106.0/23",
      "194.9.108.0/23", "194.9.110.0/23", "194.9.114.0/23"
    ]
    destination_port_ranges    = ["80", "443", "9400", "9480", "9443"]
    description                = "Allow AVD access to ZScaler for Internet Access"
  }

  security_rule {
    name                       = "avd-DenyAnyToAnyOutbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  tags = {
    name          = "ims-prd-avd-ne-nsg-personal"
    environment   = "prd"
    function      = "nsg"
    data_creation = "2025-07-21"
  }
  # depends_on = [
  #   azurerm_resource_group.ims-prd-avd-ne-rg-network
  # ]
}

#3. Create a nsg to associate with "ims-prd-avd-ne-snet-pep" subnet in the avd vNet
resource "azurerm_network_security_group" "ims-prd-avd-ne-nsg-pep" {
  provider            = azurerm.ims-prd-avd
  resource_group_name = "ims-prd-avd-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-avd-ne-nsg-pep"

  security_rule {
    name                       = "avd-DenyAnyToAnyInbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "avd-AllowDNS-TCP-Outbound"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.11.128/26"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "avd-AllowDNS-UDP-Outbound"
    priority                   = 3001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.11.128/26"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.132"
    destination_port_range     = "53"
    description                = "Allow access to DNS Private Resolver Inbound EP"
  }

  security_rule {
    name                       = "avd-AllowZscaler-UDP-Outbound"
    priority                   = 3010
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.11.128/26"
    source_port_range          = "*"
    destination_address_prefixes = [
      "147.161.224.0/23", "170.85.58.0/23", "165.225.80.0/22", "147.161.166.0/23",
      "136.226.166.0/23", "136.226.168.0/23", "147.161.140.0/23", "147.161.142.0/23",
      "147.161.144.0/23", "136.226.190.0/23", "147.161.236.0/23", "165.225.196.0/23",
      "165.225.198.0/23", "170.85.84.0/23", "194.9.112.0/23", "194.9.106.0/23",
      "194.9.108.0/23", "194.9.110.0/23", "194.9.114.0/23"
    ]
    destination_port_ranges    = ["80", "443"]
    description                = "Allow AVD access to ZScaler for Internet Access"
  }

  security_rule {
    name                       = "avd-AllowZscaler-TCP-Outbound"
    priority                   = 3011
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.11.128/26"
    source_port_range          = "*"
    destination_address_prefixes = [
      "147.161.224.0/23", "170.85.58.0/23", "165.225.80.0/22", "147.161.166.0/23",
      "136.226.166.0/23", "136.226.168.0/23", "147.161.140.0/23", "147.161.142.0/23",
      "147.161.144.0/23", "136.226.190.0/23", "147.161.236.0/23", "165.225.196.0/23",
      "165.225.198.0/23", "170.85.84.0/23", "194.9.112.0/23", "194.9.106.0/23",
      "194.9.108.0/23", "194.9.110.0/23", "194.9.114.0/23"
    ]
    destination_port_ranges    = ["80", "443", "9400", "9480", "9443"]
    description                = "Allow AVD access to ZScaler for Internet Access"
  }

  security_rule {
    name                       = "avd-DenyAnyToAnyOutbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  tags = {
    name          = "ims-prd-avd-ne-nsg-pep"
    environment   = "prd"
    function      = "nsg"
    data_creation = "2025-07-21"
  }
  # depends_on = [
  #   azurerm_resource_group.ims-prd-avd-ne-rg-network
  # ]
}
resource "azurerm_network_security_group" "ims-prd-avd-ne-nsg-mgmt" {
  provider            = azurerm.ims-prd-avd
  resource_group_name = "ims-prd-avd-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-avd-ne-nsg-mgmt"

  security_rule {
    name                       = "avd-AllowMgmt-TCP-Outbound"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.10.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.68"
    destination_port_ranges    = ["443", "1688", "80"]
  }

  security_rule {
    name                       = "avd-AllowMgmt-UDP-Outbound"
    priority                   = 3001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "192.168.10.0/24"
    source_port_range          = "*"
    destination_address_prefix = "192.168.0.68"
    destination_port_range     = "3390"
  }

  security_rule {
    name                       = "avd-DenyAnyToAnyInbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
  security_rule {
    name                       = "avd-DenyAnyToAnyOutbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
    tags = {
    name          = "ims-prd-avd-ne-nsg-mgmt"
    environment   = "prd"
    function      = "nsg"
    data_creation = "2025-07-21"
  }
  # depends_on = [
  #   azurerm_resource_group.ims-prd-avd-ne-rg-network
  # ]
}
###############################
# Create UDRs
###############################
#1. Create a udr to associate with "ims-prd-avd-ne-snet-pool" subnet in the avd vNet
resource "azurerm_route_table" "ims-prd-avd-ne-rt-pool" {
  provider            = azurerm.ims-prd-avd
  resource_group_name = "ims-prd-avd-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-avd-ne-rt-pool"

  route {
    name                   = "defaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-avd-ne-udr-vnet-aws"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-avd-ne-udr-vnet-mgmt"
    address_prefix         = "192.168.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-avd-ne-udr-snet-dnsprin"
    address_prefix         = "192.168.0.128/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-avd-ne-udr-snet-hubpep"
    address_prefix         = "192.168.1.0/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  tags = {
    name          = "ims-prd-avd-ne-rt-pool"
    environment   = "prd"
    function      = "route table"
    data_creation = "2025-07-21"
  }
  # depends_on = [
  #   azurerm_resource_group.ims-prd-avd-ne-rg-network
  # ]
}

#2. Create a udr to associate with "ims-prd-avd-ne-snet-personal" subnet in the avd vNet
resource "azurerm_route_table" "ims-prd-avd-ne-rt-personal" {
  provider            = azurerm.ims-prd-avd
  resource_group_name = "ims-prd-avd-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-avd-ne-rt-personal"

  route {
    name                   = "defaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-avd-ne-udr-vnet-aws"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-avd-ne-udr-vnet-mgmt"
    address_prefix         = "192.168.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-avd-ne-udr-snet-dnsprin"
    address_prefix         = "192.168.0.128/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }
  route {
    name                   = "ims-prd-avd-ne-udr-snet-hubpep"
    address_prefix         = "192.168.1.0/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  tags = {
    name          = "ims-prd-avd-ne-rt-personal"
    environment   = "prd"
    function      = "route table"
    data_creation = "2025-07-21"
  }
  # depends_on = [
  #   azurerm_resource_group.ims-prd-avd-ne-rg-network
  # ]
}

#3. Create a udr to associate with "ims-prd-avd-ne-rt-mgmt" subnet in the avd vNet
resource "azurerm_route_table" "ims-prd-avd-ne-rt-mgmt" {
  provider            = azurerm.ims-prd-avd
  resource_group_name = "ims-prd-avd-ne-rg-network"
  location            = "northeurope"
  name                = "ims-prd-avd-ne-rt-mgmt"

  route {
    name                   = "defaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  route {
    name                   = "ims-prd-avd-ne-udr-vnet-aws"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  route {
    name                   = "ims-prd-avd-ne-udr-vnet-mgmt"
    address_prefix         = "192.168.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  route {
    name                   = "ims-prd-avd-ne-udr-snet-dnsprin"
    address_prefix         = "192.168.0.128/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  route {
    name                   = "ims-prd-avd-ne-udr-snet-hubpep"
    address_prefix         = "192.168.1.0/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

}
################################################################
# Associate subnets with required NSG and UDR on Hub vNets
################################################################
# 1. Associate "GatewaySubnet" with "ims-prd-conn-ne-rt-vpng" route table/UDR
resource "azurerm_subnet_route_table_association" "ims-prd-conn-ne-vpng-rt" {
  provider       = azurerm.ims-prd-connectivity
  subnet_id      = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01/subnets/GatewaySubnet"
  route_table_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/routeTables/ims-prd-conn-ne-rt-vpng"
}

# 2a. Associate "ims-prd-conn-ne-snet-dnsprin" subnet with "ims-prd-conn-ne-nsg-dnsprin" nsg
resource "azurerm_subnet_network_security_group_association" "ims-prd-conn-ne-dnsprin-nsg" {
  provider                  = azurerm.ims-prd-connectivity
  subnet_id                 = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01/subnets/ims-prd-conn-ne-snet-dnsprin"
  network_security_group_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/networkSecurityGroups/ims-prd-conn-ne-nsg-dnsprin"
}

# 2b. Associate "ims-prd-conn-ne-snet-dnsprin" subnet with "ims-prd-conn-ne-rt-dnsprin" route table/UDR
resource "azurerm_subnet_route_table_association" "ims-prd-conn-ne-dnsprin-rt" {
  provider       = azurerm.ims-prd-connectivity
  subnet_id      = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01/subnets/ims-prd-conn-ne-snet-dnsprin"
  route_table_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/routeTables/ims-prd-conn-ne-rt-dnsprin"
}
# 3a. Associate "ims-prd-conn-ne-snet-dnsprout" subnet with "ims-prd-conn-ne-nsg-dnsprout" nsg
resource "azurerm_subnet_network_security_group_association" "ims-prd-conn-ne-dnsprout-nsg" {
  provider                  = azurerm.ims-prd-connectivity
  subnet_id                 = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01/subnets/ims-prd-conn-ne-snet-dnsprout"
  network_security_group_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/networkSecurityGroups/ims-prd-conn-ne-nsg-dnsprout"
}
# 3b. Associate "ims-prd-conn-ne-snet-dnsprout" subnet with "ims-prd-conn-ne-rt-dnsprout" route table/UDR
resource "azurerm_subnet_route_table_association" "ims-prd-conn-ne-dnsprout-rt" {
  provider       = azurerm.ims-prd-connectivity
  subnet_id      = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01/subnets/ims-prd-conn-ne-snet-dnsprout"
  route_table_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/routeTables/ims-prd-conn-ne-rt-dnsprout"
}
# 4. Associate "ims-prd-conn-ne-snet-pep" subnet with "ims-prd-conn-ne-nsg-pep" nsg
resource "azurerm_subnet_network_security_group_association" "ims-prd-conn-ne-pep-nsg" {
  provider                  = azurerm.ims-prd-connectivity
  subnet_id                 = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01/subnets/ims-prd-conn-ne-snet-pep"
  network_security_group_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/networkSecurityGroups/ims-prd-conn-ne-nsg-pep"
}

################################################################
# Associate subnets with required NSG and UDR on Mgmt vNets
################################################################
# 1a. Associate "ims-prd-mgmt-ne-snet-security" subnet with "ims-prd-mgmt-ne-snet-nsg-security" nsg
resource "azurerm_subnet_network_security_group_association" "ims-prd-mgmt-ne-snet-security-nsg" {
  provider                  = azurerm.ims-prd-management
  subnet_id                 = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-mgmt-ne-vnet-01/subnets/ims-prd-mgmt-ne-snet-security"
  network_security_group_id = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/networkSecurityGroups/ims-prd-mgmt-ne-nsg-security"
  
}
# 1b. Associate "ims-prd-mgmt-ne-snet-security" subnet with "ims-prd-mgmt-ne-snet-rt-security" route table/UDR
resource "azurerm_subnet_route_table_association" "ims-prd-mgmt-ne-snet-security-rt" {
  provider       = azurerm.ims-prd-management
  subnet_id      = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-mgmt-ne-vnet-01/subnets/ims-prd-mgmt-ne-snet-security"
  route_table_id = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/routeTables/ims-prd-mgmt-ne-rt-security"
  
}
# 2a. Associate "ims-prd-mgmt-ne-snet-system" subnet with "ims-prd-mgmt-ne-snet-nsg-system" nsg
resource "azurerm_subnet_network_security_group_association" "ims-prd-mgmt-ne-snet-system-nsg" {
  provider                  = azurerm.ims-prd-management
  subnet_id                 = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-mgmt-ne-vnet-01/subnets/ims-prd-mgmt-ne-snet-system"
  network_security_group_id = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/networkSecurityGroups/ims-prd-mgmt-ne-nsg-system"
   
}
# 2b. Associate "ims-prd-mgmt-ne-snet-system" subnet with "ims-prd-mgmt-ne-snet-rt-system" route table/UDR
resource "azurerm_subnet_route_table_association" "ims-prd-mgmt-ne-snet-system-rt" {
  provider       = azurerm.ims-prd-management
  subnet_id      = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-mgmt-ne-vnet-01/subnets/ims-prd-mgmt-ne-snet-system"
  route_table_id = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/routeTables/ims-prd-mgmt-ne-rt-system"
  
}
# 3a. Associate "ims-prd-mgmt-ne-snet-keyvault" subnet with "ims-prd-mgmt-ne-snet-nsg-keyvault" nsg
resource "azurerm_subnet_network_security_group_association" "ims-prd-mgmt-ne-snet-keyvault-nsg" {
  provider                  = azurerm.ims-prd-management
  subnet_id                 = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-mgmt-ne-vnet-01/subnets/ims-prd-mgmt-ne-snet-keyvault"
  network_security_group_id = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/networkSecurityGroups/ims-prd-mgmt-ne-nsg-keyvault"

}
# 3b. Associate "ims-prd-mgmt-ne-snet-keyvault" subnet with "ims-prd-mgmt-ne-snet-rt-keyvault" route table/UDR
resource "azurerm_subnet_route_table_association" "ims-prd-mgmt-ne-snet-keyvault-rt" {
  provider       = azurerm.ims-prd-management
  subnet_id      = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-mgmt-ne-vnet-01/subnets/ims-prd-mgmt-ne-snet-keyvault"
  route_table_id = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/routeTables/ims-prd-mgmt-ne-rt-keyvault"

}
################################################################
# Associate subnets with required NSG and UDR on Avd vNets
################################################################
# 1a. Associate "ims-prd-avd-ne-snet-pool" subnet with "ims-prd-avd-ne-snet-nsg-pool" nsg
resource "azurerm_subnet_network_security_group_association" "ims-prd-avd-ne-snet-pool-nsg" {
  provider                  = azurerm.ims-prd-avd
  subnet_id                 = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-avd-ne-vnet-01/subnets/ims-prd-avd-ne-snet-pool"
  network_security_group_id = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/networkSecurityGroups/ims-prd-avd-ne-nsg-pool"

}
# 1b. Associate "ims-prd-avd-ne-snet-pool" subnet with "ims-prd-avd-ne-snet-rt-pool" route table/UDR
resource "azurerm_subnet_route_table_association" "ims-prd-avd-ne-snet-pool-rt" {
  provider       = azurerm.ims-prd-avd
  subnet_id      = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-avd-ne-vnet-01/subnets/ims-prd-avd-ne-snet-pool"
  route_table_id = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/routeTables/ims-prd-avd-ne-rt-pool"

}
# 2a. Associate "ims-prd-avd-ne-snet-personal" subnet with "ims-prd-avd-ne-snet-nsg-personal" nsg
resource "azurerm_subnet_network_security_group_association" "ims-prd-avd-ne-snet-personal-nsg" {
  provider                  = azurerm.ims-prd-avd
  subnet_id                 = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-avd-ne-vnet-01/subnets/ims-prd-avd-ne-snet-personal"
  network_security_group_id = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/networkSecurityGroups/ims-prd-avd-ne-nsg-personal"

}
# 2b. Associate "ims-prd-avd-ne-snet-personal" subnet with "ims-prd-avd-ne-snet-rt-personal" route table/UDR
resource "azurerm_subnet_route_table_association" "ims-prd-avd-ne-snet-personal-rt" {
  provider       = azurerm.ims-prd-avd
  subnet_id      = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-avd-ne-vnet-01/subnets/ims-prd-avd-ne-snet-personal"
  route_table_id = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/routeTables/ims-prd-avd-ne-rt-personal"

}
# 3. Associate "ims-prd-avd-ne-snet-pep" subnet with "ims-prd-avd-ne-snet-nsg-pep" nsg
resource "azurerm_subnet_network_security_group_association" "ims-prd-avd-ne-snet-pep-nsg" {
  provider                  = azurerm.ims-prd-avd
  subnet_id                 = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-avd-ne-vnet-01/subnets/ims-prd-avd-ne-snet-pep"
  network_security_group_id = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef/resourceGroups/ims-prd-avd-ne-rg-network/providers/Microsoft.Network/networkSecurityGroups/ims-prd-avd-ne-nsg-pep"

}