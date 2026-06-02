resource "azurerm_container_app" "grafana" {
  container_app_environment_id = var.container_app_environment_id
  name                         = "app-grafana-service"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  secret {
    name  = "grafana-admin-password"
    value = var.grafana_admin_password
  }

  secret {
    name  = "grafana-postgres-password"
    value = var.grafana_postgres_password
  }

  template {
    min_replicas = 0
    max_replicas = 5
    container {
      cpu    = 0.5
      image  = "grafana/grafana:latest"
      memory = "1.0Gi"
      name   = "grafana-service"

      env {
        name  = "GF_SECURITY_ADMIN_USER"
        value = "admin"
      }

      env {
        name        = "GF_SECURITY_ADMIN_PASSWORD"
        secret_name = "grafana-admin-password"
      }

      env {
        name  = "GF_SERVER_ROOT_URL"
        value = "https://app-grafana-service.nicemeadow-e9057bda.southeastasia.azurecontainerapps.io"
      }

      env {
        name  = "GF_SERVER_PROTOCOL"
        value = "http"
      }

      env {
        name  = "GF_SERVER_FORWARDED_PROTO_HEADER"
        value = "X-Forwarded-Proto"
      }

      env {
        name  = "GF_SERVER_FORWARDED_HOST_HEADER"
        value = "X-Forwarded-Host"
      }

      env {
        name  = "GF_SERVER_ENABLE_GZIP"
        value = "true"
      }

      env {
        name  = "GF_SECURITY_COOKIE_SAMESITE"
        value = "lax"
      }

      env {
        name  = "GF_SECURITY_COOKIE_SECURE"
        value = "true"
      }

      env {
        name  = "GF_DATABASE_TYPE"
        value = "postgres"
      }

      env {
        name  = "GF_DATABASE_HOST"
        value = "${var.postgres_fqdn}:5432"
      }

      env {
        name  = "GF_DATABASE_NAME"
        value = "grafana_db"
      }

      env {
        name  = "GF_DATABASE_USER"
        value = var.postgres_user
      }

      env {
        name        = "GF_DATABASE_PASSWORD"
        secret_name = "grafana-postgres-password"
      }

      env {
        name  = "GF_DATABASE_SSL_MODE"
        value = "require"
      }

      volume_mounts {
        name = "grafana-storage-volume"
        path = "/var/lib/grafana"
      }
    }

    volume {
      name         = "grafana-storage-volume"
      storage_type = "AzureFile"
      storage_name = var.environment_share_name
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
