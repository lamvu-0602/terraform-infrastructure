data "azurerm_client_config" "current" {}

resource "azurerm_postgresql_flexible_server" "postgres_grafana" {
  name                = "pg-rooftop-kms-grafana"
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "14"
  sku_name            = "B_Standard_B1ms"
  storage_mb          = 32768
  storage_tier        = "P4"
  zone                = "1"

  administrator_login    = var.postgres_user
  administrator_password = var.grafana_postgres_password

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.postgres_grafana.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "entra_admin" {
  resource_group_name = var.resource_group_name
  object_id           = var.github_spn_object_id
  principal_name      = "github-rooftop-kms"
  principal_type      = "ServicePrincipal"
  server_name         = azurerm_postgresql_flexible_server.postgres_grafana.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
}
