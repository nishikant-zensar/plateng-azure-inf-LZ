terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"

  backend "azurerm" {
    resource_group_name  = var.backend_resource_group_name
    storage_account_name = var.backend_storage_account_name
    container_name       = var.backend_container_name
    key                  = var.backend_key # Path to the state file in the container
    use_oidc_auth        = true
    use_azuread_auth     = true
  }
}

# provider "azurerm" {
#  features {}
# }

####################################
# Create the Top Management Group  #
####################################
resource "azurerm_management_group" "TescoIMSRootMG" {
  name         = "IMS-Root"       # Unique name for the management group
  display_name = "IMS-Root"       # Friendly display name
}

##############################
# Create 1st Level Child MGs #
##############################
# Platform Root Management Group
resource "azurerm_management_group" "ims-root-platform" {
  name                          = "ims-root-platform"
  display_name                  = "ims-root-platform"
  parent_management_group_id    = azurerm_management_group.TescoIMSRootMG.id
  depends_on = [
    azurerm_management_group.TescoIMSRootMG
  ]
}
# Environments Root Management Group
resource "azurerm_management_group" "ims-root-environments" {
  name                          = "ims-root-environments"
  display_name                  = "ims-root-environments"
  parent_management_group_id    = azurerm_management_group.TescoIMSRootMG.id
  depends_on = [
    azurerm_management_group.TescoIMSRootMG
  ]
}
# Sandbox Root Management Group
resource "azurerm_management_group" "ims-root-sandbox" {
  name                          = "ims-root-sandbox"
  display_name                  = "ims-root-sandbox"
  parent_management_group_id    = azurerm_management_group.TescoIMSRootMG.id
  depends_on = [
    azurerm_management_group.TescoIMSRootMG
  ]
}
# Decommission Root Management Group
resource "azurerm_management_group" "ims-root-decommission" {
  name                          = "ims-root-decommission"
  display_name                  = "ims-root-decommission"
  parent_management_group_id    = azurerm_management_group.TescoIMSRootMG.id
  depends_on = [
    azurerm_management_group.TescoIMSRootMG
  ]
}

#################################################
# Create Child MGs under "ims-root-platform" MG #
################################################
# 1. prd platform MG under "ims-root-platform" MG
resource "azurerm_management_group" "ims-platform-prd" {
  name                          = "ims-platform-prd"
  display_name                  = "ims-platform-prd"
  parent_management_group_id    = azurerm_management_group.ims-root-platform.id
  depends_on = [
    azurerm_management_group.ims-root-platform
  ]
}

# 2. ppte platform MG under "ims-root-platform" MG
resource "azurerm_management_group" "ims-platform-ppte" {
  name                          = "ims-platform-ppte"
  display_name                  = "ims-platform-ppte"
  parent_management_group_id    = azurerm_management_group.ims-root-platform.id
  depends_on = [
    azurerm_management_group.ims-root-platform
  ]
}

#####################################################
# Create Child MGs under "ims-root-environments" MG #
#####################################################
# 1.  dev MG under "ims-root-environments" MG
resource "azurerm_management_group" "ims-env-dev" {
  name                          = "ims-env-dev"
  display_name                  = "ims-env-dev"
  parent_management_group_id    = azurerm_management_group.ims-root-environments.id
  depends_on = [
    azurerm_management_group.ims-root-environments
  ]
}

# 2. ppe (pre-production) MG under "ims-root-environments" MG
resource "azurerm_management_group" "ims-env-ppe" {
  name                          = "ims-env-ppe"
  display_name                  = "ims-env-ppe"
  parent_management_group_id    = azurerm_management_group.ims-root-environments.id
  depends_on = [
    azurerm_management_group.ims-root-environments
  ]
}
# 3. test MG under "ims-root-environments" MG
resource "azurerm_management_group" "ims-env-test" {
  name                          = "ims-env-test"
  display_name                  = "ims-env-test"
  parent_management_group_id    = azurerm_management_group.ims-root-environments.id
  depends_on = [
    azurerm_management_group.ims-root-environments
  ]
}
# 4. prd MG under "ims-root-environments" MG
resource "azurerm_management_group" "ims-env-prd" {
  name                          = "ims-env-prd"
  display_name                  = "ims-env-prd"
  parent_management_group_id    = azurerm_management_group.ims-root-environments.id
  depends_on = [
    azurerm_management_group.ims-root-environments
  ]
}

##############################################
# Associate subscriptions to respective MG's #
##############################################
# 1. Associate the Connectivity subscription with "ims-platform-prd" MG
resource "azurerm_management_group_subscription_association" "ims-platform-prd-Connectivity" {
  management_group_id = azurerm_management_group.ims-platform-prd.id
  subscription_id     = "/subscriptions/eca8a48a-2dc4-45da-908c-94bf6100016c"
  depends_on = [
    azurerm_management_group.ims-platform-prd
  ]
}

# 2. Associate the Management subscription with "ims-platform-prd" MG
resource "azurerm_management_group_subscription_association" "ims-platform-prd-management" {
  management_group_id = azurerm_management_group.ims-platform-prd.id
  subscription_id     = "/subscriptions/b63f4e55-499d-4984-9375-f17853ff6e36"
  depends_on = [
    azurerm_management_group.ims-platform-prd
  ]
}

# 3. Associate AVD Production subscription with "ims-env-prd" MG
resource "azurerm_management_group_subscription_association" "ims-env-prd-avd" {
  management_group_id = azurerm_management_group.ims-env-prd.id
  subscription_id     = "/subscriptions/9da3ee14-3ae9-4be0-9ad2-b9a7c7b059ef"
  depends_on = [
    azurerm_management_group.ims-env-prd
  ]
}