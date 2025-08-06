#####################################################
# Create Azure Firewall and Firewall Policies
#####################################################
provider "azurerm" {
  features = {}
  subscription_id = var.subscription_id
}

# 1. Create Azure Firewall Policy
resource "azurerm_firewall_policy" "fw_policy" {
  name                = "ims-prd-conn-ne-afwp-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.policy_sku

  threat_intelligence_mode = var.enable_threat_intel
  intrusion_detection {
    mode = var.idps_mode
  }
}

# 2. Create Azure Firewall
resource "azurerm_firewall" "fw" {
  name                = "ims-prd-conn-ne-afw-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  zones               = var.availability_zones

  ip_configuration {
    name                 = "firewallipconfig"
    subnet_id            = var.fw_subnet
    public_ip_address_id = var.public_ip
  }
}

output "firewall_id" {
  value = azurerm_firewall.fw.id
}
output "firewall_policy_id" {
  value = azurerm_firewall_policy.fw_policy.id
}

#####################################################################
# Create Azure DNS Private Resolver with Inbound & Outbound Endpoints
#####################################################################

provider "azurerm" {
  features {}
}

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

variable "virtual_network_id" {
  description = "Virtual Network ID"
  type        = string
}

# Create Azure DNS Private Resolver
resource "azurerm_dns_resolver" "dnspr" {
  name                = "ims-prd-conn-ne-dnspr-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.vnet

  tags = {
    Name          = "ims-prd-conn-ne-dnspr-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}
# Create DNS Private Resolver Inbound Endpoint
resource "azurerm_dns_resolver_inbound_endpoint" "inboundep" {
  name                = "ims-prd-conn-ne-in-dnspr"
  dns_resolver_id     = azurerm_dns_resolver.dnspr.id
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.dnspsubnet

  ip_configurations {
    subnet_id                     = var.dnspsubnet
    private_ip_allocation_method  = "Static"
    private_ip_address            = "192.168.0.132"
  }

  tags = {
    Name          = "ims-prd-conn-ne-in-dnspr"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}
# Create DNS Private Resolver Outbound Endpoint
resource "azurerm_dns_resolver_outbound_endpoint" "outboundep" {
  name                = "ims-prd-conn-ne-out-dnspr"
  dns_resolver_id     = azurerm_dns_resolver.dnspr.id
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.dnspoutsubnet

  tags = {
    Name          = "ims-prd-conn-ne-out-dnspr"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

# Create Outbound Endpoint Forwarding Ruleset
resource "azurerm_dns_resolver_forwarding_ruleset" "dnsfrs" {
  name                = "ims-prd-conn-ne-dnsfrs-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_resolver_id     = azurerm_dns_resolver.dnspr.id

  outbound_endpoint_ids = azurerm_dns_resolver_outbound_endpoint.outboundep

  tags = {
    Name          = "ims-prd-conn-ne-dnsfrs-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

# Create Outbound Endpoint Forwarding Rule
resource "azurerm_dns_resolver_forwarding_rule" "dnsfr" {
  name                    = "ims-prd-conn-ne-dnsfrs-rule-01"
  dns_forwarding_ruleset_id = azurerm_dns_resolver_forwarding_ruleset.dnsfrs.name
  domain_name             = "tescoims.org."
  enabled                 = "Enabled" ? true : false
  target_dns_servers {
    ip_address = "1.1.1.1"
    port       = 53
  }
}

#####################################################################
# Create Azure Key Vault
#####################################################################
# Data sources for existing resources
data "azurerm_virtual_network" "vnet" {
  name                = "ims-prd-mgmt-ne-vnet-01"
  resource_group_name = "ims-prd-mgmt-ne-rg-keyvault"
}

data "azurerm_subnet" "subnet" {
  name                 = "subnet-kv" # You must specify the actual subnet name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_private_dns_zone" "dnszone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = "ims-prd-mgmt-ne-rg-keyvault"
}

# Create Key Vault
resource "azurerm_key_vault" "kv" {
  subscription                = var.sub1
  name                        = "ims-prd-mgmt-ne-kv-01"
  location                    = var.location
  resource_group_name         = var.rgkv
  sku_name                    = "premium"
  soft_delete_enabled         = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 90

  public_network_access_enabled = false
  enable_rbac_authorization     = true

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
  }

  # Enable deployment access
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true

  tags = {
    Name          = "ims-prd-mgmt-ne-kv-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

# Private Endpoint
resource "azurerm_private_endpoint" "kvpep" {
  subscription        = var.sub1
  resource_group_name = var.rgkv
  location            = var.location
  name                = "ims-prd-mgmt-ne-pep-kv-01"

  private_service_connection {
    name                           = "kv-priv-conn"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  virtual_network_id    = var.vnetkv
  subnet_id           = var.kvsubnet
}

# Private DNS zone association
resource "azurerm_private_dns_zone_virtual_network_link" "dnslink" {
  name                  = "kv-dnslink"
  resource_group_name   = var.rgkv
  private_dns_zone_name = data.azurerm_private_dns_zone.dnszone.name
  virtual_network_id    = var.vnetkv
}

resource "azurerm_private_dns_a_record" "kv_record" {
  name                = azurerm_key_vault.kv.name
  zone_name           = data.azurerm_private_dns_zone.dnszone.name
  resource_group_name = var.rgkv
  records             = [azurerm_private_endpoint.kv_pep.private_service_connection[0].private_ip_address]
}

#####################################################################
# Create Log Analytics Workspace
#####################################################################
resource "azurerm_log_analytics_workspace" "log_analytics" {
  subscription        = var.sub1
  resource_group_name = "ims-prd-mgmt-ne-rg-network"
  name                = "ims-prd-mgmt-ne-log-analytics-01"
  location            = var.location
  
  tags = {
    Name          = "ims-prd-mgmt-ne-log-analytics-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
}
}