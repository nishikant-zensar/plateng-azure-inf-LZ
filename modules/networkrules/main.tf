###################
# Create nsg on hub vnet
###################
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

    depends_on = [
      azurerm_resource_group.ims-prd-conn-ne-rg-network
    ]
    
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

    depends_on = [
      azurerm_resource_group.ims-prd-conn-ne-rg-network
    ]

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

    depends_on = [
      azurerm_resource_group.ims-prd-conn-ne-rg-network
    ]

    tags = {
      Name          = "ims-prd-conn-ne-nsg-dnsprout"
      Environment   = "prd"
      DateCreated   = "2025-08-01"
      }
 }
###################
# Create UDR 
###################
#1. Create a udr to associate with "GatewaySubnet" subnet in hub vNet
resource "azurerm_route_table" "ims-prd-conn-ne-rt-vpng" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = "ims-prd-connectivity-rg-network"
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
  
  depends_on = [
    azurerm_resource_group.ims-prd-conn-ne-rg-network

  ]
  tags = {
    Name          = "ims-prd-conn-ne-rt-vpng"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

#2. Create a udr to associate with "ims-prd-conn-ne-snet-dnsprin" subnet subnet in hub vNet
resource "azurerm_route_table" "ims-prd-conn-ne-rt-dnsprin" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = "ims-prd-connectivity-rg-network"
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
  
  depends_on = [
    azurerm_resource_group.ims-prd-conn-ne-rg-network
  ]

  tags = {
    Name          = "ims-prd-conn-ne-rt-dnsprin"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}


#3. Create a udr to associate with "ims-prd-conn-ne-snet-dnsprout" subnet subnet in hub vNet
resource "azurerm_route_table" "ims-prd-conn-ne-rt-dnsprout" {
  provider            = azurerm.ims-prd-connectivity
  resource_group_name = "ims-prd-connectivity-rg-network"
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

  depends_on = [
    azurerm_resource_group.ims-prd-conn-ne-rg-network
  ]
  
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

  depends_on = [
    azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  ]
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

  depends_on = [
    azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  ]
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
   depends_on = [
    azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  ]
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
   depends_on = [
    azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  ]
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
  depends_on = [
    azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  ]
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
  depends_on = [
    azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  ]
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

  tags = {
    name          = "ims-prd-mgmt-ne-rt-system"
    environment   = "prd"
    function      = "route table"
    data_creation = "2025-07-21"
  }
  depends_on = [
    azurerm_resource_group.ims-prd-mgmt-ne-rg-network
  ]
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
  depends_on = [
    azurerm_resource_group.ims-prd-avd-ne-rg-network
  ]
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
  depends_on = [
    azurerm_resource_group.ims-prd-avd-ne-rg-network
  ]
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
  depends_on = [
    azurerm_resource_group.ims-prd-avd-ne-rg-network
  ]
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
  depends_on = [
    azurerm_resource_group.ims-prd-avd-ne-rg-network
  ]
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
    address_prefix         = "1192.168.1.0/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.68"
  }

  tags = {
    name          = "ims-prd-avd-ne-rt-personal"
    environment   = "prd"
    function      = "route table"
    data_creation = "2025-07-21"
  }
  depends_on = [
    azurerm_resource_group.ims-prd-avd-ne-rg-network
  ]
}