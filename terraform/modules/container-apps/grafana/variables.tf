variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "grafana_postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_fqdn" {
  type = string
}

variable "postgres_user" {
  type = string
}

variable "environment_share_name" {
  type = string
}
