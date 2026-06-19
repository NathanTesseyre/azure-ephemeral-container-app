output "acr_name" {
  value = azurerm_container_registry.demo.name
}

output "acr_login_server" {
  value = azurerm_container_registry.demo.login_server
}

output "container_app_environment_id" {
  value = azurerm_container_app_environment.demo.id
}

output "pull_identity_id" {
  value = azurerm_user_assigned_identity.pull.id
}

output "deployment_suffix" {
  value = local.suffix
}

