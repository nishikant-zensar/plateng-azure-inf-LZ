variable "connectivity_subscription_id" {
  description = "The Azure subscription ID for Connectivity"
  type        = string
  default     = "/subscriptions/ecd60543-12a0-4899-9e5f-21ec01592207"
}

variable "management_subscription_id" {
  description = "The Azure subscription ID for Management"
  type        = string
  default     = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36"
}

variable "avd_prd_subscription_id" {
  description = "The Azure subscription ID for AVD Production"
  type        = string
  default     = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "ims-prd-conn-ne-vnet-hub-01"
}

variable "vnet_resource_group" {
  description = "Resource Group Name for the Virtual Network"
  type        = string
  default     = "ims-prd-conn-ne-rg-network"
}

variable "subnet_name" {
  description = "Name of the Subnet"
  type        = string
  default     = "GatewaySubnet"
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "northeurope"
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

# variable "zones" {
#  description = "List of Availability Zones"
#  type        = type = set(string)
#  default     = "zone-redundant"
# }

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
  default     = "Microsoft Network"
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