output "acr_name" {
  value = azurerm_container_registry.demo.name
}

output "acr_login_server" {
  value = azurerm_container_registry.demo.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.demo.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.demo.admin_password
  sensitive = true
}

output "container_app_environment_id" {
  value = azurerm_container_app_environment.demo.id
}

output "deployment_suffix" {
  value = local.suffix
}
