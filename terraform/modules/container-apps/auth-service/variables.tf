variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "auth_user_username" {
  type      = string
  sensitive = true
}

variable "auth_user_password" {
  type      = string
  sensitive = true
}

variable "auth_jwt_public_key" {
  type      = string
  sensitive = true
}

variable "auth_jwt_private_key" {
  type      = string
  sensitive = true
}

variable "alloy_config" {
  type = string
}
