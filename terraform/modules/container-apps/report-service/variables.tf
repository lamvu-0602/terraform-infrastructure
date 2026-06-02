variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "report_service_token_signing_key" {
  type      = string
  sensitive = true
}

variable "jwt_jwk_set_uri" {
  type = string
}

variable "report_files_container_name" {
  type = string
}

variable "eventhub_namespace_name" {
  type = string
}

variable "eventhub_name" {
  type = string
}

variable "alloy_config" {
  type = string
}
