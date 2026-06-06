output "namespace_id" {
  value = azurerm_servicebus_namespace.asbn.id
}

output "namespace_name" {
  value = azurerm_servicebus_namespace.asbn.name
}

output "queue_id" {
  value = azurerm_servicebus_queue.learning.id
}

output "queue_name" {
  value = azurerm_servicebus_queue.learning.name
}
