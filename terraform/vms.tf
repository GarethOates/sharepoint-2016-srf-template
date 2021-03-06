data "azurerm_image" "sp2016farmImage" {
    name                = "WindowsServer2016Base"
    resource_group_name = "windows-images"
}

locals {
    admin_user = "vagrant"
    admin_pass = "Pass@word1!"
}

resource "azurerm_virtual_machine" "spfarm_db1" {
    name                  = "VERGE-DDB01"
    location              = azurerm_resource_group.sp2016rg.location
    resource_group_name   = azurerm_resource_group.sp2016rg.name
    vm_size               = "Standard_DS2_v2"
    network_interface_ids = [azurerm_network_interface.spfarm-db1.id]

    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    depends_on = [azurerm_virtual_machine.spfarm_ad1]

    storage_image_reference {
        id = data.azurerm_image.sp2016farmImage.id
    }

    storage_os_disk {
        name          = "DB1-osdisk1"
        os_type       = "Windows"
        caching       = "ReadWrite"
        create_option = "FromImage"
    }

    storage_data_disk {
        name          = "DB1-datadisk1"
        create_option = "Empty"
        lun           = 1
        disk_size_gb = 30
    }

    os_profile {
        computer_name  = "VERGE-DDB01"
        admin_username = local.admin_user
        admin_password = local.admin_pass
    }

    os_profile_windows_config {
        provision_vm_agent        = true
        enable_automatic_upgrades = true
    }
}

resource "azurerm_virtual_machine" "spfarm_sharepointweb" {
    name                  = "VERGE-DWEB01"
    location              = azurerm_resource_group.sp2016rg.location
    resource_group_name   = azurerm_resource_group.sp2016rg.name
    vm_size               = "Standard_DS2_v2"

    network_interface_ids = [azurerm_network_interface.spfarm-sharepointweb.id]

    depends_on = [azurerm_virtual_machine.spfarm_ad1]

    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        id = data.azurerm_image.sp2016farmImage.id
    }

    storage_os_disk {
        name              = "SharePoint-osdisk-web"
        os_type           = "Windows"
        caching           = "ReadWrite"
        managed_disk_type = "Standard_LRS"
        create_option     = "FromImage"
    }

    storage_data_disk {
        name          = "SharePoint-datadisk-web"
        create_option = "Empty"
        lun           = 1
        disk_size_gb = 30
    }

    os_profile {
        computer_name  = "VERGE-DWEB01"
        admin_username = local.admin_user
        admin_password = local.admin_pass
    }

    os_profile_windows_config {
        provision_vm_agent        = true
        enable_automatic_upgrades = true
    }
}

resource "azurerm_virtual_machine" "spfarm_sharepointapp" {
    name                  = "VERGE-DAPP01"
    location              = azurerm_resource_group.sp2016rg.location
    resource_group_name   = azurerm_resource_group.sp2016rg.name
    vm_size               = "Standard_DS2_v2"

    network_interface_ids = [azurerm_network_interface.spfarm-sharepointapp.id]

    depends_on = [azurerm_virtual_machine.spfarm_ad1]

    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        id = data.azurerm_image.sp2016farmImage.id
    }

    storage_os_disk {
        name              = "SharePoint-osdisk-app"
        os_type           = "Windows"
        caching           = "ReadWrite"
        managed_disk_type = "Standard_LRS"
        create_option     = "FromImage"
    }

    storage_data_disk {
        name          = "SharePoint-datadisk-app"
        create_option = "Empty"
        lun           = 1
        disk_size_gb = 30
    }

    os_profile {
        computer_name  = "VERGE-DAPP01"
        admin_username = local.admin_user
        admin_password = local.admin_pass
    }

    os_profile_windows_config {
        provision_vm_agent        = true
        enable_automatic_upgrades = true
    }
}

resource "azurerm_virtual_machine" "spfarm_ad1" {
    name                  = "VERGE-DAD01"
    location              = azurerm_resource_group.sp2016rg.location
    resource_group_name   = azurerm_resource_group.sp2016rg.name
    vm_size               = "Standard_DS2_v2"
    network_interface_ids = [azurerm_network_interface.spfarm-ad1.id]

    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        id = data.azurerm_image.sp2016farmImage.id
    }

    storage_os_disk {
        name              = "AD1-osdisk1"
        os_type           = "Windows"
        caching           = "ReadWrite"
        managed_disk_type = "Standard_LRS"
        create_option     = "FromImage"
    }

    storage_data_disk {
        name          = "AD01-datadisk1"
        create_option = "Empty"
        lun           = 1
        disk_size_gb = 30
    }

    os_profile {
        computer_name  = "VERGE-DAD01"
        admin_username = local.admin_user
        admin_password = local.admin_pass
    }

    os_profile_windows_config {
        provision_vm_agent        = true
        enable_automatic_upgrades = true
    }
}
