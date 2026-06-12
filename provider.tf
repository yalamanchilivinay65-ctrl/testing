terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
     # version = "=4.1.0" #in production always give the version number
    }
  }
  backend "azurerm" {
    resource_group_name   = "terraform-storage-gowri" #replace the same with your storage account rg
    storage_account_name  = "terrafromstoragegowri" #replace the same with your own storage account
    container_name        = "tfstate" #name of the container
    key                   = "gowri.tfstate" #state file will be stored with this name
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}