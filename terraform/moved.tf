moved {
  from = azurerm_container_registry.acr
  to   = module.acr.azurerm_container_registry.acr
}

moved {
  from = azurerm_eventhub_namespace.aehn
  to   = module.eventhub.azurerm_eventhub_namespace.aehn
}

moved {
  from = azurerm_eventhub.aeh
  to   = module.eventhub.azurerm_eventhub.aeh
}

moved {
  from = azurerm_eventhub_consumer_group.report_group
  to   = module.eventhub.azurerm_eventhub_consumer_group.report_group
}

moved {
  from = azurerm_cosmosdb_account.cosmos
  to   = module.cosmosdb.azurerm_cosmosdb_account.cosmos
}

moved {
  from = azurerm_cosmosdb_sql_database.acsql
  to   = module.cosmosdb.azurerm_cosmosdb_sql_database.acsql
}

moved {
  from = azurerm_cosmosdb_sql_container.acsql_container
  to   = module.cosmosdb.azurerm_cosmosdb_sql_container.acsql_container
}

moved {
  from = azurerm_postgresql_flexible_server.postgres_grafana
  to   = module.postgres.azurerm_postgresql_flexible_server.postgres_grafana
}

moved {
  from = azurerm_postgresql_flexible_server_firewall_rule.allow_azure
  to   = module.postgres.azurerm_postgresql_flexible_server_firewall_rule.allow_azure
}

moved {
  from = azurerm_postgresql_flexible_server_active_directory_administrator.entra_admin
  to   = module.postgres.azurerm_postgresql_flexible_server_active_directory_administrator.entra_admin
}

moved {
  from = azurerm_container_app_environment.environment
  to   = module.container_app_environment.azurerm_container_app_environment.environment
}

moved {
  from = azurerm_container_app.report_app
  to   = module.report_service.azurerm_container_app.report_app
}

moved {
  from = azurerm_container_app.ingest_app
  to   = module.data_ingest_service.azurerm_container_app.ingest_app
}

moved {
  from = azurerm_container_app.grafana
  to   = module.grafana.azurerm_container_app.grafana
}

moved {
  from = azurerm_container_app.loki
  to   = module.loki.azurerm_container_app.loki
}

moved {
  from = azurerm_container_app.prometheus
  to   = module.prometheus.azurerm_container_app.prometheus
}

moved {
  from = azurerm_role_assignment.report-service-eventhub
  to   = module.rbac.azurerm_role_assignment.report_service_eventhub
}

moved {
  from = azurerm_role_assignment.github_spn-report-service-eventhub
  to   = module.rbac.azurerm_role_assignment.github_spn_report_service_eventhub
}

moved {
  from = azurerm_role_assignment.data-ingest-service-eventhub
  to   = module.rbac.azurerm_role_assignment.data_ingest_service_eventhub
}

moved {
  from = azurerm_role_assignment.github_spn-data-ingest-service-eventhub
  to   = module.rbac.azurerm_role_assignment.github_spn_data_ingest_service_eventhub
}

moved {
  from = azurerm_role_assignment.report-service-acr
  to   = module.rbac.azurerm_role_assignment.report_service_acr
}

moved {
  from = azurerm_role_assignment.github_spn-report-service-acr
  to   = module.rbac.azurerm_role_assignment.github_spn_report_service_acr
}

moved {
  from = azurerm_role_assignment.data-ingest-service-eventhub-acr
  to   = module.rbac.azurerm_role_assignment.data_ingest_service_acr
}

moved {
  from = azurerm_role_assignment.github_spn-data-ingest-service-eventhub-acr
  to   = module.rbac.azurerm_role_assignment.github_spn_data_ingest_service_acr
}

moved {
  from = azurerm_cosmosdb_sql_role_assignment.data-ingest-service-cosmos
  to   = module.rbac.azurerm_cosmosdb_sql_role_assignment.data_ingest_service_cosmos
}

moved {
  from = azurerm_cosmosdb_sql_role_assignment.spn_cosmos_read_write_dynamic
  to   = module.rbac.azurerm_cosmosdb_sql_role_assignment.spn_cosmos_read_write_dynamic
}

moved {
  from = azurerm_storage_container.eventhub_checkpoint
  to   = module.storage.azurerm_storage_container.eventhub_checkpoint
}

moved {
  from = azurerm_storage_container.report_files
  to   = module.storage.azurerm_storage_container.report_files
}

moved {
  from = azurerm_role_assignment.data-ingest-service-blob
  to   = module.rbac.azurerm_role_assignment.data_ingest_service_blob
}

moved {
  from = azurerm_role_assignment.report-service-blob
  to   = module.rbac.azurerm_role_assignment.report_service_blob
}

moved {
  from = azurerm_role_assignment.spn_storage_blob_data_contributor
  to   = module.rbac.azurerm_role_assignment.spn_storage_blob_data_contributor
}

moved {
  from = azurerm_storage_share.grafana_storage
  to   = module.storage.azurerm_storage_share.grafana_storage
}

moved {
  from = azurerm_container_app_environment_storage.environment_share
  to   = module.storage.azurerm_container_app_environment_storage.environment_share
}
