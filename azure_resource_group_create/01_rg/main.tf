#Terraform Settings block
terraform {
  required_version = "1.11.3"

  required_providers {
    azurerm = {
    source = "hashicorp/azurerm"
    version = ">= 4.25.0"
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
resource "azurerm_resource_group" "myrg" {
  name = "DevOps-prod-eastus-01-rg"
  location = "eastus"
  #resource block to create the azure resource group
}
