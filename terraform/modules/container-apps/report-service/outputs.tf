output "principal_id" {
  value = azurerm_container_app.report_app.identity[0].principal_id
}
