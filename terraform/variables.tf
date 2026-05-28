variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "rg-rooftop-kms-training"
}

variable "location" {
  type        = string
  description = "Location"
  default     = "southeastasia"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name"
  default     = "blobkmsrooftoplamvt"
}

variable "storage_container_name" {
  type        = string
  description = "Storage container name"
  default     = "tfstate"
}

variable "grafana_admin_password" {
  type        = string
  description = "Grafana admin password"
  sensitive   = true
}

variable "postgres_user" {
  type = string
  description = "Postgres user"
  default = "grafanaadmin"
}

variable "grafana_postgres_password" {
  type        = string
  description = "Postgres password"
  sensitive = true
}