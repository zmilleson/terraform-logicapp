output "storage_account" {
    value = "${azurerm_storage_account.dataStorage.name}"
}

output "sched_container" {
    value = "${azurerm_storage_container.scheduleCont.name}"
}

output "games_container" {
    value = "${azurerm_storage_container.gamesCont.name}"
}