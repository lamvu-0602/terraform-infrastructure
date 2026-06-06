resource "azurerm_role_assignment" "report_service_eventhub" {
  principal_id         = var.report_app_principal_id
  scope                = var.eventhub_id
  role_definition_name = "Azure Event Hubs Data Sender"
}

resource "azurerm_role_assignment" "github_spn_report_service_eventhub" {
  principal_id         = var.github_spn_object_id
  scope                = var.eventhub_id
  role_definition_name = "Azure Event Hubs Data Sender"
}

resource "azurerm_role_assignment" "data_ingest_service_eventhub" {
  principal_id         = var.ingest_app_principal_id
  scope                = var.eventhub_id
  role_definition_name = "Azure Event Hubs Data Receiver"
}

resource "azurerm_role_assignment" "github_spn_data_ingest_service_eventhub" {
  principal_id         = var.github_spn_object_id
  scope                = var.eventhub_id
  role_definition_name = "Azure Event Hubs Data Receiver"
}

resource "azurerm_role_assignment" "report_service_servicebus" {
  principal_id         = var.report_app_principal_id
  scope                = var.servicebus_namespace_id
  role_definition_name = "Azure Service Bus Data Owner"
}

resource "azurerm_role_assignment" "auth_service_servicebus" {
  principal_id         = var.auth_app_principal_id
  scope                = var.servicebus_namespace_id
  role_definition_name = "Azure Service Bus Data Owner"
}

resource "azurerm_role_assignment" "data_ingest_service_servicebus" {
  principal_id         = var.ingest_app_principal_id
  scope                = var.servicebus_namespace_id
  role_definition_name = "Azure Service Bus Data Owner"
}

resource "azurerm_role_assignment" "grafana_servicebus" {
  principal_id         = var.grafana_principal_id
  scope                = var.servicebus_namespace_id
  role_definition_name = "Azure Service Bus Data Owner"
}

resource "azurerm_role_assignment" "github_spn_servicebus" {
  principal_id         = var.github_spn_object_id
  scope                = var.servicebus_namespace_id
  role_definition_name = "Azure Service Bus Data Owner"
}

resource "azurerm_role_assignment" "report_service_acr" {
  principal_id         = var.report_app_principal_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "auth_service_acr" {
  principal_id         = var.auth_app_principal_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "github_spn_report_service_acr" {
  principal_id         = var.github_spn_object_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "data_ingest_service_acr" {
  principal_id         = var.ingest_app_principal_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "github_spn_data_ingest_service_acr" {
  principal_id         = var.github_spn_object_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_cosmosdb_sql_role_assignment" "data_ingest_service_cosmos" {
  resource_group_name = var.resource_group_name
  account_name        = var.cosmos_account_name
  role_definition_id  = "${var.cosmos_account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = var.ingest_app_principal_id
  scope               = var.cosmos_account_id
}

resource "azurerm_cosmosdb_sql_role_assignment" "spn_cosmos_read_write_dynamic" {
  resource_group_name = var.resource_group_name
  account_name        = var.cosmos_account_name
  scope               = var.cosmos_account_id
  role_definition_id  = "${var.cosmos_account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = var.github_spn_object_id
}

resource "azurerm_role_assignment" "data_ingest_service_blob" {
  principal_id         = var.ingest_app_principal_id
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "report_service_blob" {
  principal_id         = var.report_app_principal_id
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "spn_storage_blob_data_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.github_spn_object_id
}
