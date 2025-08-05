variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "northeurope"
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
  default     = "zone-redundant"
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