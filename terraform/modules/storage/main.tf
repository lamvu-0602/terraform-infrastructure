data "azurerm_storage_account" "asa_bootstrap" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_container" "eventhub_checkpoint" {
  name                  = "eventhub-checkpoint"
  container_access_type = "private"
  storage_account_id    = data.azurerm_storage_account.asa_bootstrap.id
}

resource "azurerm_storage_container" "report_files" {
  name                  = "report-files"
  container_access_type = "private"
  storage_account_id    = data.azurerm_storage_account.asa_bootstrap.id
}

resource "azurerm_storage_share" "grafana_storage" {
  name               = "grafana-data-share"
  storage_account_id = data.azurerm_storage_account.asa_bootstrap.id
  quota              = 1
}

resource "azurerm_container_app_environment_storage" "environment_share" {
  name                         = "grafana-secure-volume"
  container_app_environment_id = var.container_app_environment_id
  account_name                 = data.azurerm_storage_account.asa_bootstrap.name
  access_key                   = data.azurerm_storage_account.asa_bootstrap.primary_access_key
  share_name                   = azurerm_storage_share.grafana_storage.name
  access_mode                  = "ReadWrite"
}
