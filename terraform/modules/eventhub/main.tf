resource "azurerm_eventhub_namespace" "aehn" {
  location            = var.location
  name                = "eahn-rooftop-kms-training"
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "aeh" {
  name              = "report-event-hub"
  partition_count   = 2
  message_retention = 1
  namespace_id      = azurerm_eventhub_namespace.aehn.id
}

resource "azurerm_eventhub_consumer_group" "report_group" {
  name                = "report-service-group"
  namespace_name      = azurerm_eventhub_namespace.aehn.name
  eventhub_name       = azurerm_eventhub.aeh.name
  resource_group_name = var.resource_group_name
}
