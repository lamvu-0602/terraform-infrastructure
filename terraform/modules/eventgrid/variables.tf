variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where Event Grid resources will be created."
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed."
}

variable "storage_account_id" {
  type        = string
  description = "The ID of the source Storage Account that emits events."
}

variable "servicebus_namespace_id" {
  type        = string
  description = "The ID of the target Service Bus Namespace."
}

variable "servicebus_queue_name" {
  type        = string
  description = "The name of the target Service Bus Queue to receive events."
}

variable "report_files_container_name" {
  type        = string
  description = "The name of the Blob Storage container to monitor for new files."
}