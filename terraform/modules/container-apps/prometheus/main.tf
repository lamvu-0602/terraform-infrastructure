resource "azurerm_container_app" "prometheus" {
  container_app_environment_id = var.container_app_environment_id
  name                         = "app-prometheus-service"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  secret {
    name  = "prometheus-config-${substr(sha1(var.prometheus_config), 0, 7)}"
    value = var.prometheus_config
  }

  template {
    container {
      cpu    = 0.25
      memory = "0.5Gi"
      name   = "prometheus"
      image  = "prom/prometheus:latest"

      args = [
        "--config.file=/etc/prometheus/prometheus-config-${substr(sha1(var.prometheus_config), 0, 7)}",
        "--web.enable-remote-write-receiver"
      ]

      volume_mounts {
        name = "prometheus-config-volume"
        path = "/etc/prometheus"
      }
    }

    min_replicas = 1
    max_replicas = 2

    volume {
      name         = "prometheus-config-volume"
      storage_type = "Secret"
    }
  }

  ingress {
    external_enabled = false
    target_port      = 9090
    transport        = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
