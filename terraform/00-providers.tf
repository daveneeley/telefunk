terraform {
  backend "azurerm" {
    resource_group_name  = "{{ .terraform_backend_resource_group }}"
    storage_account_name = "{{ .terraform_backend_storage_account }}"
    container_name       = "terraformdeployments"
    key                  = "{{ .deployment_name }}.tfstate"
  }
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
