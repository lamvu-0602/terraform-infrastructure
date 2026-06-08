resource "azurerm_eventgrid_system_topic" "storage_topic" {
  name                = "st-blob-events-topic"
  resource_group_name = var.resource_group_name
  location            = var.location
  source_resource_id  = var.storage_account_id
  topic_type          = "Microsoft.Storage.StorageAccounts"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "storage_to_servicebus" {
  name                          = "sub-blob-to-servicebus"
  system_topic                  = azurerm_eventgrid_system_topic.storage_topic.name
  resource_group_name           = var.resource_group_name
  service_bus_queue_endpoint_id = "${var.servicebus_namespace_id}/queues/${var.servicebus_queue_name}"
  included_event_types = [
    "Microsoft.Storage.BlobCreated"
  ]
  subject_filter {
    subject_begins_with = "/blobServices/default/containers/${var.report_files_container_name}"
  }
}