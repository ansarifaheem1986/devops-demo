resource "azurerm_resource_group" "mydevoops" {
  name = var.resource_group_name
  location = var.location
}