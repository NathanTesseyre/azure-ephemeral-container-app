resource "azurerm_container_app" "demo" {
  name                         = "ca-demo-${var.deployment_suffix}"
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  registry {
    server               = var.acr_login_server
    username             = var.acr_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = var.acr_password
  }

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "api"
      image  = "${var.acr_login_server}/azure-ephemeral-app:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "APP_VERSION"
        value = var.image_tag
      }

      liveness_probe {
        transport        = "HTTP"
        port             = 3000
        path             = "/health"
        interval_seconds = 10
      }

      readiness_probe {
        transport        = "HTTP"
        port             = 3000
        path             = "/health"
        interval_seconds = 5
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = {
    project    = "azure-ephemeral-container-app"
    managed-by = "terraform"
    ephemeral  = "true"
    ci-run-id  = var.run_id
  }
}
