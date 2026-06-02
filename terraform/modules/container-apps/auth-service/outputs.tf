output "principal_id" {
  value = azurerm_container_app.auth_app.identity[0].principal_id
}

output "jwk_set_uri" {
  value = "https://${azurerm_container_app.auth_app.ingress[0].fqdn}/auth/jwks"
}
