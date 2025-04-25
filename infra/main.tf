terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-devops-crm"
    storage_account_name = "tfstatecrmdevops"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}



# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-devops-crm"
  location = "East US"
}

# Storage Account for app assets/logs (NOT the Terraform backend)
resource "azurerm_storage_account" "logs" {
  name                     = "crmlogs${random_id.storage.hex}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
}

resource "random_id" "storage" {
  byte_length = 4
}

# Azure App Service Plan (Linux)
resource "azurerm_service_plan" "app_plan" {
  name                = "asp-crm-dev"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# Azure Web App (Linux with Docker container)
resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-crm-dev"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.acr.login_server}/crm-app:latest"
      docker_image_tag = "latest"
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"         = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"    = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"    = azurerm_container_registry.acr.admin_password
    "APPINSIGHTS_INSTRUMENTATIONKEY"     = azurerm_application_insights.app_insights.instrumentation_key
  }
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrcrmdevops"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "appi-crm-dev"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
}
