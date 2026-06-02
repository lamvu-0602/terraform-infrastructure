resource "azurerm_container_app" "ingest_app" {
  container_app_environment_id = var.container_app_environment_id
  name                         = "app-data-ingest-service"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  secret {
    name  = "alloy-config-${substr(sha1(var.alloy_config), 0, 7)}"
    value = var.alloy_config
  }

  template {
    container {
      cpu    = 0.5
      image  = "${var.acr_login_server}/data-ingest-service:latest"
      memory = "1.0Gi"
      name   = "data-ingest-service"

      env {
        name  = "STORAGE_ACCOUNT_NAME"
        value = var.storage_account_name
      }

      env {
        name  = "STORAGE_BLOB_ENDPOINT"
        value = "https://${var.storage_account_name}.blob.core.windows.net/"
      }

      env {
        name  = "AZURE_EVENTHUBS_NAMESPACE"
        value = var.eventhub_namespace_name
      }

      env {
        name  = "EVENTHUB_DESTINATION"
        value = var.eventhub_name
      }

      env {
        name  = "EVENTHUB_GROUP"
        value = var.eventhub_consumer_group_name
      }

      env {
        name  = "COSMOS_ENDPOINT"
        value = var.cosmos_endpoint
      }

      env {
        name  = "COSMOS_DATABASE"
        value = var.cosmos_database_name
      }

      env {
        name  = "CHECKPOINT_CONTAINER"
        value = var.eventhub_checkpoint_container_name
      }

      env {
        name  = "REPORT_CONTAINER"
        value = var.report_files_container_name
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
      name   = "data-ingest-service-alloy"

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

  registry {
    server   = var.acr_login_server
    identity = "system"
  }
}
