terraform {
  backend "azurerm" {
    resource_group_name  = "infra_rg"
    storage_account_name = "infrastanstorageaccount"
    container_name       = "terraform"
    access_key           = "GVq0zEDpb2lfiZT7j8CZzKgV4pKedcftDwMJqumcOlPeBOXaltPJj2kmXmfXdlsZicabNUrz6Om1+ASt5Vfl/g=="
    key                  = "userservice.terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
