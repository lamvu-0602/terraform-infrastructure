variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "postgres_user" {
  type = string
}

variable "grafana_postgres_password" {
  type      = string
  sensitive = true
}

variable "github_spn_object_id" {
  type = string
}
