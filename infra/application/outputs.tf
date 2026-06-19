output "application_url" {
  value = "https://${azurerm_container_app.demo.latest_revision_fqdn}"
}

