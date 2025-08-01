terraform {
  required_version = "1.11.3"
  required_providers {
    azurerm = {
        version = "hashicorp/azurerm"
        source = ">= 4.25.0"
    }
  }
   backend "azurerm" {
    resource_group_name  = "terraform-storage-files-01-rg"
    storage_account_name = "tfstatefilesdevprd"
    container_name       = "githubaction"
    key                  = "azure_rg_create_destroy/rg.terraform.state"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "d49174c3-680b-4508-a934-4fe38df8598f"
}