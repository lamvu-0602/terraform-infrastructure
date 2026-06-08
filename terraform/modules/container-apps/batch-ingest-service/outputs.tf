output "principal_id" {
  value = azurerm_container_app.batch_ingest_app.identity[0].principal_id
}