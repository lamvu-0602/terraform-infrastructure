resource "azurerm_servicebus_namespace" "asbn" {
  name                = "asbn-rooftop-kms-training"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"
}

resource "azurerm_servicebus_queue" "learning" {
  name                  = "report-queue"
  namespace_id          = azurerm_servicebus_namespace.asbn.id
  max_size_in_megabytes = 1024

  max_delivery_count = 3
  requires_session   = true
  # requires_duplicate_detection            = true | remove because using 'Basic' tier
  # duplicate_detection_history_time_window = "PT10M"
}
