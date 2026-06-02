output "fqdn" {
  value = azurerm_postgresql_flexible_server.postgres_grafana.fqdn
}

output "server_name" {
  value = azurerm_postgresql_flexible_server.postgres_grafana.name
}
