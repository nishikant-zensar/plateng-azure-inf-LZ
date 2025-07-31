output "management_group_ids" {
  value = {
    platform_group_id     = azurerm_management_group.ims-root-platform.id
    environments_group_id  = azurerm_management_group.ims-root-environments.id
    sandbox_group_id      = azurerm_management_group.ims-root-sandbox.id
    decommissioned_group_id = azurerm_management_group.ims-root-decommission.id
  }
}
