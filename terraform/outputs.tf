output "acr_login_server" {
  value = module.acr.login_server
}

output "servicebus_namespace_name" {
  value = module.servicebus.namespace_name
}

output "servicebus_queue_name" {
  value = module.servicebus.queue_name
}
