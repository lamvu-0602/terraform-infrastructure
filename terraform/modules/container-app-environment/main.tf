resource "azurerm_container_app_environment" "environment" {
  location            = var.location
  name                = "rooftop-kms-enviroment"
  resource_group_name = var.resource_group_name
}
