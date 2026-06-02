resource "azurerm_container_app" "loki" {
  container_app_environment_id = var.container_app_environment_id
  name                         = "app-loki-service"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      cpu    = 0.25
      memory = "0.5Gi"
      name   = "loki"
      image  = "grafana/loki:3.0.0"

      args = ["-config.file=/etc/loki/local-config.yaml"]
    }

    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    external_enabled = false
    target_port      = 3100
    transport        = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
