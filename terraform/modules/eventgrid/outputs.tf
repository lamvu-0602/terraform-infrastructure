output "system_topic_principal_id" {
  value = azurerm_eventgrid_system_topic.storage_topic.identity[0].principal_id
}

output "system_topic_id" {
  value = azurerm_eventgrid_system_topic.storage_topic.id
}

output "subscription_id" {
  value = azurerm_eventgrid_system_topic_event_subscription.storage_to_servicebus.id
}