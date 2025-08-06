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
  description = "Azure Firewall ID"
}
output "firewall_policy_id" {
  value = azurerm_firewall_policy.fw_policy.id
  description = "Firewall Policy ID"
}

# Firewall Rule Collection
resource "azurerm_firewall_policy_rule_collection_group" "coreplat_group" {
  name                = "ims-prd-conn-ne-afwprcg-coreplat"
  resource_group_name = var.resource_group_name
  location            = var.location
  priority           = 100

  nat_rule_collection {
    name     = "ims-prd-conn-ne-afwprc-coreplat-dnat"
    priority = 100
    action   = "Allow"

  }
  network_rule_collection {
    name     = "ims-prd-conn-ne-afwprc-coreplat-net"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "ims-prd-conn-ne-afwpr-awsdns-out"
      source_addresses      = ["192.168.0.192/26"]
      destination_addresses = ["10.0.0.0/8"]
      protocols             = ["TCP", "UDP"]
      destination_ports     = ["53"]
      description           = "Enables Azure DNS Private Resolver to forward DNS queries to IMS AWS for conditional forwarding. We should restrict the 10.0.0.0/8 address to a longer prefix once we know what the IP address(es) of the AWS DNS Servers are."
    }

    rule {
      name                  = "ims-prd-conn-ne-afwpr-dns-in"
      source_addresses      = ["10.0.0.0/8", "192.168.4.0/22", "192.168.8.0/22"]
      destination_addresses = ["192.168.0.132"]
      protocols             = ["TCP", "UDP"]
      destination_ports     = ["53"]
      description           = "Enable DNS queries to Azure DNS Private Resolver"
    }

    rule {
      name                  = "ims-prd-conn-ne-afwpr-ziatcp-out"
      source_addresses      = ["192.168.8.0/22"]
      destination_addresses = ["147.161.224.0/23,170.85.58.0/23,165.225.80.0/22,147.161.166.0/23,136.226.166.0/23,136.226.168.0/23,147.161.140.0/23,147.161.142.0/23,147.161.144.0/23,136.226.190.0/23,147.161.236.0/23,165.225.196.0/23,165.225.198.0/23,170.85.84.0/23,194.9.112.0/23,194.9.106.0/23,194.9.108.0/23,194.9.110.0/23,194.9.114.0/23"]
      protocols             = ["TCP"]
      destination_ports     = ["80, 443, 9400, 9480, 9443"]
      description           = "Probably best creating an IP Group with these zscaler IPs, rather than adding them to this rule individually, as it's easier to manage if the IPs change in future."
    }

    rule {
      name                  = "ims-prd-conn-ne-afwpr-ziaudp-out"
      source_addresses      = ["192.168.8.0/22"]
      destination_addresses = ["147.161.224.0/23,170.85.58.0/23,165.225.80.0/22,147.161.166.0/23,136.226.166.0/23,136.226.168.0/23,147.161.140.0/23,147.161.142.0/23,147.161.144.0/23,136.226.190.0/23,147.161.236.0/23,165.225.196.0/23,165.225.198.0/23,170.85.84.0/23,194.9.112.0/23,194.9.106.0/23,194.9.108.0/23,194.9.110.0/23,194.9.114.0/23"]
      protocols             = ["UDP"]
      destination_ports     = ["80, 443"]
      description           = "Probably best creating an IP Group with these zscaler IPs, rather than adding them to this rule individually, as it's easier to manage if the IPs change in future."
    }
  }
  application_rule_collection {
    name     = "ims-prd-conn-ne-afwprc-coreplat-app"
    priority = 300
    action   = "Allow"
  }
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