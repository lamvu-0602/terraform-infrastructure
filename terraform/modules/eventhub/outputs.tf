output "eventhub_id" {
  value = azurerm_eventhub.aeh.id
}

output "eventhub_name" {
  value = azurerm_eventhub.aeh.name
}

output "namespace_name" {
  value = azurerm_eventhub_namespace.aehn.name
}

output "consumer_group_name" {
  value = azurerm_eventhub_consumer_group.report_group.name
}
