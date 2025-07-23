# Public IP

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

provider "azurerm" {
  features        = {}
  subscription_id = var.subscription_id
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "public_ip_name" {
  description = "Name of the Public IP"
  type        = string
}

variable "ip_version" {
  description = "IP Version (IPv4 or IPv6)"
  type        = string
  default     = "IPv4"
}

variable "sku" {
  description = "SKU (Basic or Standard)"
  type        = string
  default     = "Standard"
}

variable "zones" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = []
}

variable "tier" {
  description = "Tier (Regional or Global)"
  type        = string
  default     = "Regional"
}

variable "allocation_method" {
  description = "IP Address Assignment (Static or Dynamic)"
  type        = string
  default     = "Static"
}

variable "routing_preference" {
  description = "Routing Preference (Internet or Microsoft)"
  type        = string
  default     = "Internet"
}

variable "idle_timeout_in_minutes" {
  description = "Idle timeout in minutes"
  type        = number
  default     = 4
}

variable "domain_name_label" {
  description = "Domain name label (for DNS)"
  type        = string
  default     = null
}

variable "ddos_protection_mode" {
  description = "DDoS Protection Mode (Enabled, Disabled, or null for inherited)"
  type        = string
  default     = null
}

resource "azurerm_public_ip" "this" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  allocation_method   = var.allocation_method
  ip_version          = var.ip_version
  zones               = var.zones
  tier                = var.tier
  domain_name_label   = var.domain_name_label
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  public_ip_prefix_id = null

  # Routing Preference (Internet, Microsoft), only valid for Standard SKU with IPv4
  routing_preference = var.routing_preference

  # DDoS protection is only available for Standard SKU
  ddos_protection_mode = var.ddos_protection_mode
}

# VPN Gateway

provider "azurerm" {
  features = {}
  # If you use multiple subscriptions, specify subscription_id here.
  # subscription_id = "SUBSCRIPTION_ID_FOR_ims-prd-connectivity"
}

data "azurerm_resource_group" "vpn" {
  name = "ims-prd-conn-ne-rg-network"
}

data "azurerm_virtual_network" "hub_vnet" {
  name                = "ims-prd-conn-ne-vnet-hub-01"
  resource_group_name = data.azurerm_resource_group.vpn.name
}

data "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  virtual_network_name = data.azurerm_virtual_network.hub_vnet.name
  resource_group_name  = data.azurerm_resource_group.vpn.name
}

data "azurerm_public_ip" "pip1" {
  name                = "ims-prd-conn-ne-pip-vpng-01"
  resource_group_name = data.azurerm_resource_group.vpn.name
}

data "azurerm_public_ip" "pip2" {
  name                = "ims-prd-conn-ne-pip-vpng-02"
  resource_group_name = data.azurerm_resource_group.vpn.name
}

resource "azurerm_virtual_network_gateway" "vpn_gw" {
  name                = "ims-prd-conn-ne-vpng-01"
  location            = data.azurerm_resource_group.vpn.location
  resource_group_name = data.azurerm_resource_group.vpn.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw2AZ"
  generation = "Generation2"

  active_active = true

  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = data.azurerm_public_ip.pip1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.gateway_subnet.id
  }

  ip_configuration {
    name                          = "vnetGatewayConfig2"
    public_ip_address_id          = data.azurerm_public_ip.pip2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.gateway_subnet.id
  }

  enable_bgp = false
  # Key Vault Access, Managed Identity, and Authentication Information (preview) not enabled.
}

# Azure Firewall

# Variables
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "firewall_name" {
  description = "Azure Firewall Name"
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = []
}

variable "firewall_sku_name" {
  description = "Firewall SKU (AZFW_VNet or AZFW_Hub)"
  type        = string
}

variable "firewall_sku_tier" {
  description = "Firewall SKU Tier (Standard, Premium, or Basic)"
  type        = string
}

variable "policy_name" {
  description = "Firewall Policy Name"
  type        = string
}

variable "policy_location" {
  description = "Firewall Policy Region"
  type        = string
}

variable "policy_sku" {
  description = "Firewall Policy Tier (Standard or Premium)"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
}

variable "address_space" {
  description = "Address space for VNet"
  type        = list(string)
}

variable "subnet_name" {
  description = "Subnet Name"
  type        = string
  default     = "AzureFirewallSubnet"
}

variable "subnet_prefix" {
  description = "Address prefix for firewall subnet"
  type        = string
}

variable "public_ip_name" {
  description = "Name of the Public IP for Firewall"
  type        = string
}

variable "enable_threat_intel" {
  description = "Enable Threat Intelligence mode (Off, Alert, Deny)"
  type        = string
  default     = "Alert"
}

variable "idps_mode" {
  description = "IDPS mode (Off, Alert, Deny)"
  type        = string
  default     = "Alert"
}

# Provider
provider "azurerm" {
  features = {}
  subscription_id = var.subscription_id
}

# Resource Group (Data)
data "azurerm_resource_group" "fw_rg" {
  name = var.resource_group_name
}

# Public IP (Data)
data "azurerm_public_ip" "firewall_pip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
}

# Virtual Network
resource "azurerm_virtual_network" "fw_vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Subnet
resource "azurerm_subnet" "fw_subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.fw_vnet.name
  address_prefixes     = [var.subnet_prefix]
  delegation {
    name = "AzureFirewallSubnet"
    service_delegation {
      name = "Microsoft.Network/azureFirewalls"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# Firewall Policy
resource "azurerm_firewall_policy" "fw_policy" {
  name                = var.policy_name
  location            = var.policy_location
  resource_group_name = var.resource_group_name
  sku                 = var.policy_sku

  threat_intelligence_mode = var.enable_threat_intel
  intrusion_detection {
    mode = var.idps_mode
  }
}

# Azure Firewall
resource "azurerm_firewall" "fw" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  zones               = var.availability_zones

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fw_subnet.id
    public_ip_address_id = data.azurerm_public_ip.firewall_pip.id
  }
}

output "firewall_id" {
  value = azurerm_firewall.fw.id
}
output "firewall_policy_id" {
  value = azurerm_firewall_policy.fw_policy.id
}

# Route Table
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "route_table_name" {
  description = "Route Table Name"
  type        = string
}

variable "propagate_gateway_routes" {
  description = "Propagate Gateway Routes (true or false)"
  type        = bool
}

provider "azurerm" {
  features        = {}
  subscription_id = var.subscription_id
}

resource "azurerm_route_table" "this" {
  name                          = var.route_table_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = !var.propagate_gateway_routes
  tags = {
    environment = "managed-by-terraform"
  }
}

output "route_table_id" {
  value = azurerm_route_table.this.id
}
