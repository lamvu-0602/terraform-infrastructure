resource "azurerm_container_app" "report_app" {
  container_app_environment_id = var.container_app_environment_id
  name                         = "app-report-service"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  secret {
    name  = "alloy-config-${substr(sha1(var.alloy_config), 0, 7)}"
    value = var.alloy_config
  }

  secret {
    name  = "jwt-token-signing-key"
    value = var.report_service_token_signing_key
  }

  template {
    min_replicas = 0
    max_replicas = 10
    container {
      cpu    = 0.5
      image  = "${var.acr_login_server}/report-service:latest"
      memory = "1.0Gi"
      name   = "report-service"

      env {
        name  = "AZURE_STORAGE_BLOB_ACCOUNT_NAME"
        value = var.storage_account_name
      }

      env {
        name        = "JWT_TOKEN_SIGNING_KEY"
        secret_name = "jwt-token-signing-key"
      }

      env {
        name  = "JWT_JWK_SET_URI"
        value = var.jwt_jwk_set_uri
      }

      env {
        name  = "AZURE_STORAGE_BLOB_ENDPOINT"
        value = "https://${var.storage_account_name}.blob.core.windows.net/"
      }

      env {
        name  = "AZURE_STORAGE_BLOB_CONTAINER_NAME"
        value = var.report_files_container_name
      }

      env {
        name  = "AZURE_EVENTHUBS_NAMESPACE"
        value = var.eventhub_namespace_name
      }

      env {
        name  = "AZURE_EVENTHUBS_DESTINATION"
        value = var.eventhub_name
      }

      env {
        name  = "AZURE_SERVICEBUS_NAMESPACE"
        value = var.servicebus_namespace_name
      }

      env {
        name  = "AZURE_SERVICEBUS_QUEUE_NAME"
        value = var.servicebus_queue_name
      }

      volume_mounts {
        name = "shared-log-volume"
        path = "/mnt/shared-logs"
      }
    }

    container {
      cpu    = 0.25
      image  = "docker.io/grafana/alloy:latest"
      memory = "0.5Gi"
      name   = "report-service-alloy"

      env {
        name  = "ALLOY_DEPLOY_MODE"
        value = "sidecar"
      }

      args = [
        "run",
        "/etc/alloy/alloy-config-${substr(sha1(var.alloy_config), 0, 7)}",
        "--storage.path=/tmp/alloy-data"
      ]

      volume_mounts {
        name = "alloy-config-volume"
        path = "/etc/alloy"
      }

      volume_mounts {
        name = "shared-log-volume"
        path = "/mnt/shared-logs"
      }
    }

    volume {
      name         = "alloy-config-volume"
      storage_type = "Secret"
    }

    volume {
      name         = "shared-log-volume"
      storage_type = "EmptyDir"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8080

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server   = var.acr_login_server
    identity = "system"
  }
}
