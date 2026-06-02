output "storage_account_id" {
  value = data.azurerm_storage_account.asa_bootstrap.id
}

output "report_files_container_name" {
  value = azurerm_storage_container.report_files.name
}

output "eventhub_checkpoint_container_name" {
  value = azurerm_storage_container.eventhub_checkpoint.name
}

output "environment_share_name" {
  value = azurerm_container_app_environment_storage.environment_share.name
}
