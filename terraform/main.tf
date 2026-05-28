terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-rooftop-kms-training"
    storage_account_name = "blobkmsrooftoplamvt"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_container_registry" "acr" {
  name                = "acrrooftopkmstraining"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_eventhub_namespace" "aehn" {
  location            = var.location
  name                = "eahn-rooftop-kms-training"
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "aeh" {
  name              = "report-event-hub"
  partition_count   = 2
  message_retention = 1
  namespace_id      = azurerm_eventhub_namespace.aehn.id
}

resource "azurerm_eventhub_consumer_group" "report_group" {
  name                = "report-service-group"
  namespace_name      = azurerm_eventhub_namespace.aehn.name
  eventhub_name       = azurerm_eventhub.aeh.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_cosmosdb_account" "cosmos" {
  location            = var.location
  name                = "rooftop-kms-cosmos-db"
  offer_type          = "Standard"
  resource_group_name = var.resource_group_name
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "acsql" {
  account_name        = azurerm_cosmosdb_account.cosmos.name
  name                = "data-ingest"
  resource_group_name = var.resource_group_name
}

resource "azurerm_cosmosdb_sql_container" "acsql_container" {
  account_name          = azurerm_cosmosdb_account.cosmos.name
  database_name         = azurerm_cosmosdb_sql_database.acsql.name
  name                  = "reports"
  partition_key_paths   = ["/report_type"]
  partition_key_version = 1
  resource_group_name   = var.resource_group_name
}

resource "azurerm_postgresql_flexible_server" "postgres_grafana" {
  name                   = "pg-rooftop-kms-grafana"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "14"
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  storage_tier           = "P4"

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "entra_admin" {
  server_id           = azurerm_postgresql_flexible_server.postgres_grafana.id
  resource_group_name = var.resource_group_name
  object_id           = data.azuread_service_principal.github_spn.object_id
  principal_name      = "github-rooftop-kms"
  principal_type      = "ServicePrincipal"
  server_name         = azurerm_postgresql_flexible_server.postgres_grafana.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_container_app_environment" "environment" {
  location            = var.location
  name                = "rooftop-kms-enviroment"
  resource_group_name = var.resource_group_name
}

resource "azurerm_container_app" "report_app" {
  container_app_environment_id = azurerm_container_app_environment.environment.id
  name                         = "app-report-service"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  secret {
    name  = "alloy-config-${substr(sha1(file("${path.module}/report-config.alloy")), 0, 7)}"
    value = file("${path.module}/report-config.alloy")
  }

  template {
    container {
      cpu    = 0.5
      image  = "${azurerm_container_registry.acr.login_server}/report-service:latest"
      memory = "1.0Gi"
      name   = "report-service"

      env {
        name  = "AZURE_STORAGE_BLOB_ACCOUNT_NAME"
        value = var.storage_account_name
      }

      env {
        name  = "AZURE_STORAGE_BLOB_ENDPOINT"
        value = "https://${var.storage_account_name}.blob.core.windows.net/"
      }

      env {
        name  = "AZURE_STORAGE_BLOB_CONTAINER_NAME"
        value = azurerm_storage_container.report_files.name
      }

      env {
        name  = "AZURE_EVENTHUBS_NAMESPACE"
        value = azurerm_eventhub_namespace.aehn.name
      }

      env {
        name  = "AZURE_EVENTHUBS_DESTINATION"
        value = azurerm_eventhub.aeh.name
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
        "/etc/alloy/alloy-config-secret",
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
    server   = azurerm_container_registry.acr.login_server
    identity = "system"
  }

  # lifecycle {
  #   ignore_changes = [
  #     template,
  #   ]
  # }
}

resource "azurerm_container_app" "ingest_app" {
  container_app_environment_id = azurerm_container_app_environment.environment.id
  name                         = "app-data-ingest-service"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  secret {
    name  = "alloy-config-${substr(sha1(file("${path.module}/report-config.alloy")), 0, 7)}"
    value = file("${path.module}/data-ingest-config.alloy")
  }

  template {
    container {
      cpu    = 0.5
      image  = "${azurerm_container_registry.acr.login_server}/data-ingest-service:latest"
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
        value = azurerm_eventhub_namespace.aehn.name
      }
      env {
        name  = "EVENTHUB_DESTINATION"
        value = azurerm_eventhub.aeh.name
      }
      env {
        name  = "COSMOS_ENDPOINT"
        value = azurerm_cosmosdb_account.cosmos.endpoint
      }
      env {
        name  = "COSMOS_DATABASE"
        value = azurerm_cosmosdb_sql_database.acsql.name
      }
      env {
        name  = "CHECKPOINT_CONTAINER"
        value = azurerm_storage_container.eventhub_checkpoint.name
      }
      env {
        name  = "REPORT_CONTAINER"
        value = azurerm_storage_container.report_files.name
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
        "/etc/alloy/alloy-config-secret",
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
    server   = azurerm_container_registry.acr.login_server
    identity = "system"
  }

  # lifecycle {
  #   ignore_changes = [
  #     template,
  #   ]
  # }
}

resource "azurerm_container_app" "grafana" {
  container_app_environment_id = azurerm_container_app_environment.environment.id
  name                         = "app-grafana-service"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  template {
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
        name  = "GF_SECURITY_ADMIN_PASSWORD"
        value = var.grafana_admin_password
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
        value = "none"
      }

      env {
        name  = "GF_SECURITY_COOKIE_SECURE"
        value = "true"
      }

      # test
      env {
        name  = "GF_SECURITY_SECRET_KEY"
        value = "KMS_Training_Secret_Key_Super_Secure_123456789_A@B"
      }

      env {
        name  = "GF_DATABASE_TYPE"
        value = "postgres"
      }
      env {
        name  = "GF_DATABASE_HOST"
        value = "${azurerm_postgresql_flexible_server.postgres_grafana.fqdn}:5432"
      }
      env {
        name  = "GF_DATABASE_NAME"
        value = "grafana_db"
      }
      env {
        name  = "GF_DATABASE_USER"
        value = "app-grafana-service"
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
      storage_name = azurerm_container_app_environment_storage.environment_share.name
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

resource "azurerm_container_app" "loki" {
  container_app_environment_id = azurerm_container_app_environment.environment.id
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

resource "azurerm_container_app" "prometheus" {
  container_app_environment_id = azurerm_container_app_environment.environment.id
  name                         = "app-prometheus-service"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      cpu    = 0.25
      memory = "0.5Gi"
      name   = "prometheus"
      image  = "prom/prometheus:latest"

      args = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--web.enable-remote-write-receiver"
      ]
    }
    min_replicas = 1
    max_replicas = 1
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

data "azuread_service_principal" "github_spn" {
  client_id = "b42fcaa9-18ae-4e77-9dfc-3f1dbbedabcc"
}

data "azurerm_storage_account" "asa_bootstrap" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "report-service-eventhub" {
  principal_id         = azurerm_container_app.report_app.identity[0].principal_id
  scope                = azurerm_eventhub.aeh.id
  role_definition_name = "Azure Event Hubs Data Sender"
}

resource "azurerm_role_assignment" "github_spn-report-service-eventhub" {
  principal_id         = data.azuread_service_principal.github_spn.object_id
  scope                = azurerm_eventhub.aeh.id
  role_definition_name = "Azure Event Hubs Data Sender"
}

resource "azurerm_role_assignment" "data-ingest-service-eventhub" {
  principal_id         = azurerm_container_app.ingest_app.identity[0].principal_id
  scope                = azurerm_eventhub.aeh.id
  role_definition_name = "Azure Event Hubs Data Receiver"
}

resource "azurerm_role_assignment" "github_spn-data-ingest-service-eventhub" {
  principal_id         = data.azuread_service_principal.github_spn.object_id
  scope                = azurerm_eventhub.aeh.id
  role_definition_name = "Azure Event Hubs Data Receiver"
}

resource "azurerm_role_assignment" "report-service-acr" {
  principal_id         = azurerm_container_app.report_app.identity[0].principal_id
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "github_spn-report-service-acr" {
  principal_id         = data.azuread_service_principal.github_spn.object_id
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "data-ingest-service-eventhub-acr" {
  principal_id         = azurerm_container_app.ingest_app.identity[0].principal_id
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "github_spn-data-ingest-service-eventhub-acr" {
  principal_id         = data.azuread_service_principal.github_spn.object_id
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
}

resource "azurerm_cosmosdb_sql_role_assignment" "data-ingest-service-cosmos" {
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  role_definition_id  = "${azurerm_cosmosdb_account.cosmos.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002" # "Cosmos DB Built-in Data Contributor"
  principal_id        = azurerm_container_app.ingest_app.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.cosmos.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "spn_cosmos_read_write_dynamic" {
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  scope               = azurerm_cosmosdb_account.cosmos.id

  role_definition_id = "${azurerm_cosmosdb_account.cosmos.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"

  principal_id = data.azuread_service_principal.github_spn.object_id
}

resource "azurerm_storage_container" "eventhub_checkpoint" {
  name                  = "eventhub-checkpoint"
  container_access_type = "private"
  storage_account_id    = data.azurerm_storage_account.asa_bootstrap.id
}

resource "azurerm_storage_container" "report_files" {
  name                  = "report-files"
  container_access_type = "private"
  storage_account_id    = data.azurerm_storage_account.asa_bootstrap.id
}

resource "azurerm_role_assignment" "data-ingest-service-blob" {
  principal_id         = azurerm_container_app.ingest_app.identity[0].principal_id
  scope                = data.azurerm_storage_account.asa_bootstrap.id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "report-service-blob" {
  principal_id         = azurerm_container_app.report_app.identity[0].principal_id
  scope                = data.azurerm_storage_account.asa_bootstrap.id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "spn_storage_blob_data_contributor" {
  scope                = data.azurerm_storage_account.asa_bootstrap.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.github_spn.object_id
}

resource "azurerm_storage_share" "grafana_storage" {
  name               = "grafana-data-share"
  storage_account_id = data.azurerm_storage_account.asa_bootstrap.id
  quota              = 1
}

resource "azurerm_container_app_environment_storage" "environment_share" {
  name                         = "grafana-secure-volume"
  container_app_environment_id = azurerm_container_app_environment.environment.id
  account_name                 = data.azurerm_storage_account.asa_bootstrap.name
  access_key                   = data.azurerm_storage_account.asa_bootstrap.primary_access_key
  share_name                   = azurerm_storage_share.grafana_storage.name
  access_mode                  = "ReadWrite"
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}