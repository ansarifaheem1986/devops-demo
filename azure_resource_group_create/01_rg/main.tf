#Terraform Settings block
terraform {
  required_version = "1.11.3"

  required_providers {
    azurerm = {
    source = "hashicorp/azurerm"
    version = ">= 4.25.0"
   }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "d49174c3-680b-4508-a934-4fe38df8598f"
}
resource "azurerm_resource_group" "myrg" {
  name = "DevOps2-nonprod-eastus-01-rg"
  location = "eastus"
  #resource block to create the azure resource group
}