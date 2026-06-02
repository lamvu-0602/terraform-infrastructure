resource "azurerm_container_app" "auth_app" {
  container_app_environment_id = var.container_app_environment_id
  name                         = "app-auth-service"
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
    name  = "auth-user-username"
    value = var.auth_user_username
  }

  secret {
    name  = "auth-user-password"
    value = var.auth_user_password
  }

  secret {
    name  = "auth-jwt-public-key"
    value = var.auth_jwt_public_key
  }

  secret {
    name  = "auth-jwt-private-key"
    value = var.auth_jwt_private_key
  }

  template {
    min_replicas = 0
    max_replicas = 10
    container {
      cpu    = 0.5
      image  = "${var.acr_login_server}/report-service:latest"
      memory = "1.0Gi"
      name   = "auth-service"

      env {
        name        = "AUTH_USER_USERNAME"
        secret_name = "auth-user-username"
      }

      env {
        name        = "AUTH_USER_PASSWORD"
        secret_name = "auth-user-password"
      }

      env {
        name        = "AUTH_JWT_PUBLIC_KEY"
        secret_name = "auth-jwt-public-key"
      }

      env {
        name        = "AUTH_JWT_PRIVATE_KEY"
        secret_name = "auth-jwt-private-key"
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
      name   = "auth-service-alloy"

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
    target_port      = 8082

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
