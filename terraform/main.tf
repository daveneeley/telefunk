terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "=3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_user_assigned_identity" "this" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  name = "uai-telefunc"
}

data "azurerm_container_registry" "this" {
  name                = var.registry_name
  resource_group_name = var.registry_rg
}

resource "azurerm_role_assignment" "this" {
  scope                = data.azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# Create resource group
resource "azurerm_resource_group" "this" {
  name     = "rg-${var.deployment_name}-${var.location}"
  location = var.location
}

resource "azurerm_storage_account" "this" {
  name                     = substr(base64encode("lfasa${var.deployment_name}"), 5, 15)
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "this" {
  name                = "lfasp-${var.deployment_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "this" {
  name                = "lfa-${var.deployment_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  service_plan_id = azurerm_service_plan.this.id

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  storage_account {
    name         = "config-${var.deployment_name}"
    account_name = azurerm_storage_account.this.name
    access_key   = azurerm_storage_account.this.primary_access_key
    share_name   = "configshare-${var.deployment_name}"
    type         = "AzureFiles"
    mount_path   = "/etc/teleport"
  }

  storage_account {
    name         = "data-${var.deployment_name}"
    account_name = azurerm_storage_account.this.name
    access_key   = azurerm_storage_account.this.primary_access_key
    share_name   = "datashare-${var.deployment_name}"
    type         = "AzureFiles"
    mount_path   = "/var/lib/teleport"
  }

  https_only = true
  site_config {
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.this.client_id
    container_registry_use_managed_identity       = true
    application_stack {
      docker_image     = var.container_image_url
      docker_image_tag = var.container_image_tag
    }
  }
}
