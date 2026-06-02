data "azuread_service_principal" "github_spn" {
  client_id = var.service_principal_github
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "eventhub" {
  source              = "./modules/eventhub"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "cosmosdb" {
  source              = "./modules/cosmosdb"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "postgres" {
  source                    = "./modules/postgres"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  postgres_user             = var.postgres_user
  grafana_postgres_password = var.grafana_postgres_password
  github_spn_object_id      = data.azuread_service_principal.github_spn.object_id
}

module "container_app_environment" {
  source              = "./modules/container-app-environment"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "storage" {
  source                       = "./modules/storage"
  resource_group_name          = var.resource_group_name
  storage_account_name         = var.storage_account_name
  container_app_environment_id = module.container_app_environment.id
}

module "report_service" {
  source                           = "./modules/container-apps/report-service"
  resource_group_name              = var.resource_group_name
  container_app_environment_id     = module.container_app_environment.id
  acr_login_server                 = module.acr.login_server
  storage_account_name             = var.storage_account_name
  report_service_token_signing_key = var.report_service_token_signing_key
  report_files_container_name      = module.storage.report_files_container_name
  eventhub_namespace_name          = module.eventhub.namespace_name
  eventhub_name                    = module.eventhub.eventhub_name
  alloy_config                     = file("${path.root}/configs/report-config.alloy")
}

module "data_ingest_service" {
  source                             = "./modules/container-apps/data-ingest-service"
  resource_group_name                = var.resource_group_name
  container_app_environment_id       = module.container_app_environment.id
  acr_login_server                   = module.acr.login_server
  storage_account_name               = var.storage_account_name
  eventhub_namespace_name            = module.eventhub.namespace_name
  eventhub_name                      = module.eventhub.eventhub_name
  eventhub_consumer_group_name       = module.eventhub.consumer_group_name
  cosmos_endpoint                    = module.cosmosdb.endpoint
  cosmos_database_name               = module.cosmosdb.database_name
  eventhub_checkpoint_container_name = module.storage.eventhub_checkpoint_container_name
  report_files_container_name        = module.storage.report_files_container_name
  alloy_config                       = file("${path.root}/configs/data-ingest-config.alloy")
}

module "grafana" {
  source                       = "./modules/container-apps/grafana"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = module.container_app_environment.id
  grafana_admin_password       = var.grafana_admin_password
  grafana_postgres_password    = var.grafana_postgres_password
  postgres_fqdn                = module.postgres.fqdn
  postgres_user                = var.postgres_user
  environment_share_name       = module.storage.environment_share_name
}

module "loki" {
  source                       = "./modules/container-apps/loki"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = module.container_app_environment.id
}

module "prometheus" {
  source                       = "./modules/container-apps/prometheus"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = module.container_app_environment.id
  prometheus_config            = file("${path.root}/configs/prometheus.yml")
}

module "rbac" {
  source                  = "./modules/rbac"
  resource_group_name     = var.resource_group_name
  report_app_principal_id = module.report_service.principal_id
  ingest_app_principal_id = module.data_ingest_service.principal_id
  github_spn_object_id    = data.azuread_service_principal.github_spn.object_id
  eventhub_id             = module.eventhub.eventhub_id
  acr_id                  = module.acr.id
  cosmos_account_id       = module.cosmosdb.account_id
  cosmos_account_name     = module.cosmosdb.account_name
  storage_account_id      = module.storage.storage_account_id
}
