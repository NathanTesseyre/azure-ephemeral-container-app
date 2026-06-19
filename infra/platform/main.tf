data "azurerm_resource_group" "demo" {
  name = var.resource_group_name
}

resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

locals {
  suffix = random_string.suffix.result
  tags = {
    project    = "azure-ephemeral-container-app"
    managed-by = "terraform"
    ephemeral  = "true"
    ci-run-id  = var.run_id
  }
}

resource "azurerm_container_registry" "demo" {
  name                = "acrdemo${local.suffix}"
  resource_group_name = data.azurerm_resource_group.demo.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = local.tags
}

resource "azurerm_log_analytics_workspace" "demo" {
  name                = "log-aca-${local.suffix}"
  resource_group_name = data.azurerm_resource_group.demo.name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_container_app_environment" "demo" {
  name                       = "cae-demo-${local.suffix}"
  resource_group_name        = data.azurerm_resource_group.demo.name
  location                   = var.location
  logs_destination           = "log-analytics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.demo.id
  tags                       = local.tags
}
