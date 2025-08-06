# Public IP

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

provider "azurerm" {
  features        = {}
  subscription_id = var.subscription_id
}

#####################################################
# Create Public IP's for Gateway and Firewall
#####################################################
# 1. Create "ims-prd-conn-ne-pip-vpng-01" Public IP for VPN Gateway

resource "azurerm_public_ip" "pipvpng01" {
  name                = ims-prd-conn-ne-pip-vpng-01
  resource_group_name = "ims-prd-conn-ne-rg-network"
  location            = var.location
  sku                 = var.sku
  allocation_method   = var.allocation_method
  ip_version          = var.ip_version
  zones               = var.zones
  tier                = var.tier
  domain_name_label   = var.domain_name_label
  idle_timeout_in_minutes = var.idle_timeout_in_minutes

  # Routing Preference (Internet, Microsoft), only valid for Standard SKU with IPv4
  routing_preference = var.routing_preference

  # DDoS protection is only available for Standard SKU
  # ddos_protection_mode = var.ddos_protection_mode
  tags = {
    Name          = "ims-prd-conn-ne-pip-vpng-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}
# 2. Create "ims-prd-conn-ne-pip-vpng-02" Public IP for VPN Gateway

resource "azurerm_public_ip" "pipvpng02" {
  name                = ims-prd-conn-ne-pip-vpng-02
  resource_group_name = "ims-prd-conn-ne-rg-network"
  location            = var.location
  sku                 = var.sku
  allocation_method   = var.allocation_method
  ip_version          = var.ip_version
  zones               = var.zones
  tier                = var.tier
  domain_name_label   = var.domain_name_label
  idle_timeout_in_minutes = var.idle_timeout_in_minutes

  # Routing Preference (Internet, Microsoft), only valid for Standard SKU with IPv4
  routing_preference = var.routing_preference

  # DDoS protection is only available for Standard SKU
  # ddos_protection_mode = var.ddos_protection_mode
  tags = {
    Name          = "ims-prd-conn-ne-pip-vpng-02"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

# 3. Create "ims-prd-conn-ne-pip-afw-01" Public IP for VPN Gateway

resource "azurerm_public_ip" "pipafw01" {
  name                = ims-prd-conn-ne-pip-afw-01
  resource_group_name = "ims-prd-conn-ne-rg-network"
  location            = var.location
  sku                 = var.sku
  allocation_method   = var.allocation_method
  ip_version          = var.ip_version
  zones               = var.zones
  tier                = var.tier
  domain_name_label   = var.domain_name_label
  idle_timeout_in_minutes = var.idle_timeout_in_minutes

  # Routing Preference (Internet, Microsoft), only valid for Standard SKU with IPv4
  routing_preference = var.routing_preference

  # DDoS protection is only available for Standard SKU
  # ddos_protection_mode = var.ddos_protection_mode
  tags = {
    Name          = "ims-prd-conn-ne-pip-afw-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

#####################################################
# Create Virtual Private Gateway and Local Network Gateways
#####################################################
# 1. Create ims-prd-conn-ne-vpng-01 VPN Gateway

provider "azurerm" {
  features {}
  # Optionally set subscription_id if needed
  # subscription_id = "<your-subscription-id>"
}

# Data sources for existing resources

data "azurerm_virtual_network" "vnethub" {
  name                = "ims-prd-conn-ne-vnet-hub-01"
  resource_group_name = "ims-prd-conn-ne-rg-network"
}

data "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  virtual_network_name = data.azurerm_virtual_network.vnethub.name
  resource_group_name  = data.azurerm_virtual_network.vnethub.resource_group_name
}

data "azurerm_public_ip" "pip1" {
  name                = "ims-prd-conn-ne-pip-vpng-01"
  resource_group_name = "ims-prd-conn-ne-rg-network"
}

data "azurerm_public_ip" "pip2" {
  name                = "ims-prd-conn-ne-pip-vpng-02"
  resource_group_name = "ims-prd-conn-ne-rg-network"
}

resource "azurerm_virtual_network_gateway" "vpn_gw" {
  subscription        = var.connectivity_subscription_id
  name                = "ims-prd-conn-ne-vpng-01"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.vpn.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw2AZ"
  generation = "Generation2"

  active_active = true

  ip_configuration {
    name                          = "vpng-ipconfig1"
    public_ip_address_id          = data.azurerm_public_ip.pip1.name
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.gateway_subnet.id
  }

  ip_configuration {
    name                          = "vpng-ipconfig2"
    public_ip_address_id          = data.azurerm_public_ip.pip2.name
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.gateway_subnet.id
  }

  enable_bgp = false
  # Key Vault Access, Managed Identity, and Authentication Information (preview) not enabled.
  
  tags = {
    Name          = "ims-prd-conn-ne-vpng-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}
# 2. Create Local Network Gateway 1 on VPN Gateway

resource "azurerm_local_network_gateway" "aws_lgw1" {
  name                = "ims-prd-conn-ne-lgw-aws-01"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.vpn.name
  gateway_address     = "46.137.123.146"
  address_space       = [
    "10.0.0.0/14"
  ]
}

# 3. Create Local Network Gateway 2 on VPN Gateway
resource "azurerm_local_network_gateway" "aws_lgw2" {
  name                = "ims-prd-conn-ne-lgw-aws-02"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.vpn.name
  gateway_address     = "52.213.177.71"
  address_space       = [
    "10.0.0.0/14"
  ]
}

# 4. Create Gateway Connection 1 on VPN Gateway

resource "azurerm_virtual_network_gateway_connection" "s2s_connection1" {
  name                            = "ims-prd-conn-ne-vnc-01"
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.vpn.name
  type                            = "IPsec"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vpn_gw.name
  local_network_gateway_id        = azurerm_local_network_gateway.aws_lgw1.name
  connection_protocol             = "IKEv2"
  shared_key                      = "<your-shared-key>" # Replace with your actual pre-shared key
  dpd_timeout_seconds             = 45
  use_policy_based_traffic_selectors = true

  # IPsec/IKE policy is default (no custom policy block)
  # NAT Rules not configured

  tags = {
    Name          = "ims-prd-conn-ne-vnc-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
}
}
# 5. Create Gateway Connection 2 on VPN Gateway

resource "azurerm_virtual_network_gateway_connection" "s2s_connection2" {
  name                            = "ims-prd-conn-ne-vnc-02"
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.vpn.name
  type                            = "IPsec"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vpn_gw.name
  local_network_gateway_id        = azurerm_local_network_gateway.aws_lgw2.name
  connection_protocol             = "IKEv2"
  shared_key                      = "<your-shared-key>" # Replace with your actual pre-shared key
  dpd_timeout_seconds             = 45
  use_policy_based_traffic_selectors = true

  # IPsec/IKE policy is default (no custom policy block)
  # NAT Rules not configured

  tags = {
    Name          = "ims-prd-conn-ne-vnc-02"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
}
}