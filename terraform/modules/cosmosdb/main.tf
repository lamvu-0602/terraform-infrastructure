resource "azurerm_cosmosdb_account" "cosmos" {
  location            = var.location
  name                = "rooftop-kms-cosmos-db"
  offer_type          = "Standard"
  resource_group_name = var.resource_group_name
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "acsql" {
  account_name        = azurerm_cosmosdb_account.cosmos.name
  name                = "data-ingest"
  resource_group_name = var.resource_group_name
}

resource "azurerm_cosmosdb_sql_container" "acsql_container" {
  account_name          = azurerm_cosmosdb_account.cosmos.name
  database_name         = azurerm_cosmosdb_sql_database.acsql.name
  name                  = "reports"
  partition_key_paths   = ["/report_type"]
  partition_key_version = 1
  resource_group_name   = var.resource_group_name
}
