## Variable Inputs ##
variable "rg_name" {}
variable "rg_location" {}
variable "prefix" {}

## Resources ##
# Create Storage account to store CFB Data
resource "azurerm_storage_account" "dataStorage" {
    name                        = "${var.prefix}cfbdata"
    resource_group_name         = "${var.rg_name}"
    location                    = "${var.rg_location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    account_kind                = "StorageV2"
}

# Create Containers within storage account
resource "azurerm_storage_container" "scheduleCont" {
    name                    = "fullgameschedule"
    resource_group_name     = "${var.rg_name}"
    storage_account_name    = "${azurerm_storage_account.dataStorage.name}"
    container_access_type   = "private"
}

resource "azurerm_storage_container" "gamesCont" {
    name                    = "individualgames"
    resource_group_name     = "${var.rg_name}"
    storage_account_name    = "${azurerm_storage_account.dataStorage.name}"
    container_access_type   = "private"
}