terraform {
  backend "azurerm" {
    resource_group_name  = "ims-prd-lz-ne-rg-terraformstate"
    storage_account_name = "imslandingznstr"
    container_name       = "tfstate"
    key                  = "azservices.terraform.tfstate" # Path to the state file in the container
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
#####################################################
# Create Azure Firewall and Firewall Policies
#####################################################

# 1. Create Azure Firewall Policy
resource "azurerm_firewall_policy" "fw_policy" {
  name                = "ims-prd-conn-ne-afwp-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku             = "Premium"

  threat_intelligence_mode = "Alert"

  # IDPS configuration
  intrusion_detection {
    mode = "Alert"
  }

  # TLS inspection (Explicitly Disabled)
  # tls_inspection {
  #  enabled = false
  # }
}

# 2. Create Azure Firewall
resource "azurerm_firewall" "fw" {
  name                = "ims-prd-conn-ne-afw-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  zones               = ["1"]

  ip_configuration {
    name                 = "firewallipconfig"
    subnet_id            = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01/subnets/AzureFirewallSubnet"
    public_ip_address_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/publicIPAddresses/ims-prd-conn-ne-pip-afw-01"
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
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  # resource_group_name = var.resource_group_name
  # location            = var.location
  priority           = 100

  # nat_rule_collection {
  #   name     = "ims-prd-conn-ne-afwprc-coreplat-dnat"
  #  priority = 100
  #  action   = "Allow"

  #}
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
      destination_ports     = ["80", "443", "9400", "9480", "9443"]
      description           = "Probably best creating an IP Group with these zscaler IPs, rather than adding them to this rule individually, as it's easier to manage if the IPs change in future."
    }

    rule {
      name                  = "ims-prd-conn-ne-afwpr-ziaudp-out"
      source_addresses      = ["192.168.8.0/22"]
      destination_addresses = ["147.161.224.0/23,170.85.58.0/23,165.225.80.0/22,147.161.166.0/23,136.226.166.0/23,136.226.168.0/23,147.161.140.0/23,147.161.142.0/23,147.161.144.0/23,136.226.190.0/23,147.161.236.0/23,165.225.196.0/23,165.225.198.0/23,170.85.84.0/23,194.9.112.0/23,194.9.106.0/23,194.9.108.0/23,194.9.110.0/23,194.9.114.0/23"]
      protocols             = ["UDP"]
      destination_ports     = ["80", "443"]
      description           = "Probably best creating an IP Group with these zscaler IPs, rather than adding them to this rule individually, as it's easier to manage if the IPs change in future."
    }
    
# rule {
#      name                  = "ims-prd-conn-ne-afwpr-mgmtst-out"
#      source_addresses      = ["192.168.10.0/24"]
#      destination_service_tags = ["WindowsVirtualDesktop, AzureMonitor, EventHub"]
#      protocols             = ["TCP"]
#      destination_ports     = ["443"]
#      description           = "The AVD session hosts needs to access this list of FQDNs and endpoints for Azure Virtual Desktop. All entries are outbound, it is not required to open inbound ports for AVD"
#    }

rule {
      name                  = "ims-prd-conn-ne-afwpr-mgmtip-out"
      source_addresses      = ["192.168.10.0/24"]
      destination_addresses = ["169.254.169.254,168.63.129.16"]
      protocols             = ["TCP"]
      destination_ports     = ["80"]
      description           = "The AVD session hosts needs to access this list of FQDNs and endpoints for Azure Virtual Desktop. All entries are outbound, it is not required to open inbound ports for AVD."
    }
  }
   
 application_rule_collection {
    name     = "ims-prd-conn-ne-afwprc-coreplat-app"
    priority = 300
    action   = "Allow"

   rule {
      name                  = "ims-prd-conn-ne-afwpr-mgmtfqdn-out"
      source_addresses      = ["192.168.10.0/24"]
      destination_fqdns     = ["login.microsoftonline.com","*.wvd.microsoft.com","catalogartifact.azureedge.net","*.prod.warm.ingest.monitor.core.windows.net","gcs.prod.monitoring.core.windows.net","azkms.core.windows.net","mrsglobalsteus2prod.blob.core.windows.net","wvdportalstorageblob.blob.core.windows.net","oneocsp.microsoft.com","www.microsoft.com","aka.ms","login.windows.net","*.events.data.microsoft.com","www.msftconnecttest.com","*.prod.do.dsp.mp.microsoft.com","*.sfx.ms","*.digicert.com","*.azure-dns.com","*.azure-dns.net","*eh.servicebus.windows.net"]
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      # protocols             = ["http","https"]
      # destination_ports     = ["80","443","1688"]
      description           = "The AVD session hosts needs to access these FQDNs and endpoints for Azure Virtual Desktop. All entries are outbound, it is not required to open inbound ports for AVD."
    }
    }
}

#####################################################################
# Create Azure DNS Private Resolver with Inbound & Outbound Endpoints
#####################################################################

# Create Azure DNS Private Resolver
resource "azurerm_private_dns_resolver" "dnspr" {
  name                = "ims-prd-conn-ne-dnspr-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01"

  tags = {
    Name          = "ims-prd-conn-ne-dnspr-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}
# Create DNS Private Resolver Inbound Endpoint
resource "azurerm_private_dns_resolver_inbound_endpoint" "inboundep" {
  name                = "ims-prd-conn-ne-in-dnspr"
  private_dns_resolver_id = azurerm_private_dns_resolver.dnspr.id
  # resource_group_name = var.resource_group_name
  location            = var.location
  # subnet_id           = var.dnspinsubnet

  ip_configurations {
    subnet_id                     = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01/subnets/ims-prd-conn-ne-snet-dnsprin"
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
resource "azurerm_private_dns_resolver_outbound_endpoint" "outboundep" {
  name                = "ims-prd-conn-ne-out-dnspr"
  private_dns_resolver_id     = azurerm_private_dns_resolver.dnspr.id
  # resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-conn-ne-vnet-hub-01/subnets/ims-prd-conn-ne-snet-dnsprout"

  tags = {
    Name          = "ims-prd-conn-ne-out-dnspr"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

# Create Outbound Endpoint Forwarding Ruleset
resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "dnsfrs" {
  name                = "ims-prd-conn-ne-dnsfrs-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  # private_dns_resolver_id     = azurerm_private_dns_resolver.dnspr.id

  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.outboundep.id]
  tags = {
    Name          = "ims-prd-conn-ne-dnsfrs-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

# Create Outbound Endpoint Forwarding Rule 1
resource "azurerm_private_dns_resolver_forwarding_rule" "dnsfr" {
  name                    = "ims-prd-conn-ne-dnsfrs-rule-01"
  dns_forwarding_ruleset_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/dnsForwardingRulesets/ims-prd-conn-ne-dnsfrs-01"
  domain_name             = "tescoims.org."
  enabled                 = true
  target_dns_servers {
    ip_address = "1.1.1.1"
    port       = 53
  }
}
# Create Outbound Endpoint Forwarding Rule 2
resource "azurerm_private_dns_resolver_forwarding_rule" "dnsfr2" {
  name                    = "ims-prd-conn-ne-dnsfrs-rule-02"
  dns_forwarding_ruleset_id = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207/resourceGroups/ims-prd-conn-ne-rg-network/providers/Microsoft.Network/dnsForwardingRulesets/ims-prd-conn-ne-dnsfrs-01"
  domain_name             = "aws.tescoimscloud.org."
  enabled                 = true
  target_dns_servers {
    ip_address = "1.1.1.1"
    port       = 53
  }
}

#####################################################################
# Create Azure Key Vault
#####################################################################

provider "azurerm" {
  features{}
  alias           = "ims-prd-management"
  subscription_id = "b63f4e55-499d-4984-9375-f17853ff6e36"
  tenant_id       = "684d2402-0ea6-442d-9ad7-4ef26b925ec5"
  client_id       = "74925104-cd8b-47e5-b29a-83a75a2f4ca6"
}

# Data sources for existing resources
# data "azurerm_virtual_network" "vnet" {
#  name                = "ims-prd-mgmt-ne-vnet-01"
#  resource_group_name = "ims-prd-mgmt-ne-rg-keyvault"
#  provider = azurerm.ims-prd-management
#}

data "azurerm_resource_group" "connsub" {
  name     = "ims-prd-conn-ne-rg-network"
  provider = azurerm.ims-prd-connectivity
}
data "azurerm_resource_group" "mgmtsub" {
  name     = "ims-prd-mgmt-ne-rg-keyvault"
  provider = azurerm.ims-prd-management
}

data "azurerm_resource_group" "mgmtsub2" {
  name     = "ims-prd-mgmt-ne-rg-network"
  provider = azurerm.ims-prd-management
}

# data "azurerm_subnet" "subnet" {
#  name                 = "subnet-kv" # You must specify the actual subnet name
#  virtual_network_name = data.azurerm_virtual_network.vnet.name
#  resource_group_name  = data.azurerm_resource_group.mgmtsub.name
# }

# data "azurerm_private_dns_zone" "dnszone" {
#  name                = "privatelink.vaultcore.azure.net"
#  resource_group_name = data.azurerm_resource_group.mgmtsub.name
# }

# Create Key Vault
resource "azurerm_key_vault" "kv" {
  provider                    = azurerm.ims-prd-management
  # subscription                = ["b63f4e55-499d-4984-9375-f17853ff6e36"]
  name                        = "ims-prd-mgmt-ne-kv-10"
  location                    = var.location
  resource_group_name         = data.azurerm_resource_group.mgmtsub.name
  sku_name                    = "premium"
  tenant_id                   = "684d2402-0ea6-442d-9ad7-4ef26b925ec5"
  # soft_delete_enabled         = true
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
    Name          = "ims-prd-mgmt-ne-kv-10"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
  }
}

# Private Endpoint
resource "azurerm_private_endpoint" "kvpep" {
  provider              = azurerm.ims-prd-management
  # subscription        = var.sub1
  resource_group_name = data.azurerm_resource_group.mgmtsub.name
  location            = var.location
  name                = "ims-prd-mgmt-ne-pep-kv-10"
  subnet_id           = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-mgmt-ne-vnet-01/subnets/ims-prd-mgmt-ne-snet-keyvault"

  private_service_connection {
    name                           = "kv-priv-conn"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  # virtual_network_id    = var.vnetkv
  
}
# Create Private DNS Zone
resource "azurerm_private_dns_zone" "dnszone" {
  provider              = azurerm.ims-prd-management
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = data.azurerm_resource_group.mgmtsub2.name
}

# Private DNS zone association
resource "azurerm_private_dns_zone_virtual_network_link" "dnslink" {
  provider              = azurerm.ims-prd-management
  name                  = "kv-dnslink"
  resource_group_name   = data.azurerm_resource_group.mgmtsub2.name
  private_dns_zone_name = azurerm_private_dns_zone.dnszone.name
  virtual_network_id    = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36/resourceGroups/ims-prd-mgmt-ne-rg-network/providers/Microsoft.Network/virtualNetworks/ims-prd-mgmt-ne-vnet-01"
}

resource "azurerm_private_dns_a_record" "kv_record" {
  provider            = azurerm.ims-prd-management
  name                = azurerm_key_vault.kv.name
  zone_name           = "privatelink.vaultcore.azure.net"
  resource_group_name = data.azurerm_resource_group.mgmtsub2.name
  records             = [azurerm_private_endpoint.kvpep.private_service_connection[0].private_ip_address]
  ttl                 = 300
}

#####################################################################
# Create Log Analytics Workspace
#####################################################################
resource "azurerm_log_analytics_workspace" "log_analytics" {
  provider              = azurerm.ims-prd-management
  # subscription        = ["b63f4e55-499d-4984-9375-f17853ff6e36"]
  resource_group_name = data.azurerm_resource_group.mgmtsub2.name
  name                = "ims-prd-mgmt-ne-log-analytics-01"
  location            = var.location
  
  tags = {
    Name          = "ims-prd-mgmt-ne-log-analytics-01"
    Environment   = "prd"
    DateCreated   = "2025-08-01"
}

}
#####################################################################
# Create Private DNS Zones
#####################################################################
resource "azurerm_private_dns_zone" "multi" {
  provider            = azurerm.ims-prd-connectivity
  for_each            = toset(var.private_dns_zones)
  name                = each.value
  resource_group_name = data.azurerm_resource_group.connsub.name
}










