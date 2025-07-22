variable "root_management_group_id" {
  description = "The ID of the root management group (usually your tenant ID or 'root')."
  type        = string
  default     = "/providers/Microsoft.Management/managementGroups/TescoIMSRootMG"
}

variable "backend_resource_group_name" {
  description = "The name of the backend resource group"
  type        = string
}

variable "backend_storage_account_name" {
  description = "The name of the backend storage account"
  type        = string
}

variable "backend_container_name" {
  description = "The name of the backend container"
  type        = string
}

variable "backend_key" {
  description = "The key for the backend state file"
  type        = string
  default     = "managementgroups.terraform.tfstate"
}
# variable "tags" {
 # description = "Tags to assign to the Azure resources"
 # type        = map(string)
 # default     = {
 #   Name        = "ims-prd-avd-ne-rg-network"
 #   Environment = "prd"
 #   DateCreated = "2025-07-01"
 # }
# }
variable "tags" {
  description = "Tags to assign to the Azure resource"
  type        = map(string)
  default     = {}
}
