output "principal_id" {
  value = azurerm_container_app.grafana.identity[0].principal_id
}
