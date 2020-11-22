// resource "azurerm_virtual_network" "spfarmstaging-vnet" {
//     name                = "spfarm_staging_network"
//     address_space       = ["10.10.0.0/16"]
//     location            = azurerm_resource_group.sp2016rg.location
//     resource_group_name = azurerm_resource_group.sp2016rg.name
// }

// resource "azurerm_subnet" "backendsubnet" {
//     name                 = "spfarm-subnet-backend"
//     address_prefixes     = ["10.10.1.0/24"]
//     virtual_network_name = azurerm_virtual_network.spfarmstaging-vnet.name
//     resource_group_name  = azurerm_resource_group.sp2016rg.name
// }

// resource "azurerm_subnet" "frontendsubnet" {
//     name                 = "spfarm-subnet-frontend"
//     address_prefixes     = ["10.10.2.0/24"]
//     virtual_network_name = azurerm_virtual_network.spfarmstaging-vnet.name
//     resource_group_name  = azurerm_resource_group.sp2016rg.name
// }

// resource "azurerm_network_security_group" "spfarm-security-group-backend" {
//     name                = "spfarm-security-group-backend"
//     location            = azurerm_resource_group.sp2016rg.location
//     resource_group_name = azurerm_resource_group.sp2016rg.name

//     security_rule {
//         name                       = "SSH"
//         priority                   = 1001
//         direction                  = "Inbound"
//         access                     = "Allow"
//         protocol                   = "Tcp"
//         source_port_range          = "*"
//         destination_port_range     = "22"
//         source_address_prefix      = "*"
//         destination_address_prefix = "*"
//     }

//     security_rule {
//         name                       = "WinRM"
//         priority                   = 1002
//         direction                  = "Inbound"
//         access                     = "Allow"
//         protocol                   = "Tcp"
//         source_port_range          = "*"
//         destination_port_range     = "5985"
//         source_address_prefix      = "*"
//         destination_address_prefix = "*"
//     }

//     security_rule {
//         name                       = "RDP"
//         priority                   = 1003
//         direction                  = "Inbound"
//         access                     = "Allow"
//         protocol                   = "Tcp"
//         source_port_range          = "*"
//         destination_port_range     = "3389"
//         source_address_prefix      = "*"
//         destination_address_prefix = "*"
//     }
// }

// resource "azurerm_network_security_group" "spfarm-security-group-frontend" {
//     name                = "spfarm-security-group-frontend"
//     location            = azurerm_resource_group.sp2016rg.location
//     resource_group_name = azurerm_resource_group.sp2016rg.name

//     security_rule {
//         name                       = "SSH"
//         priority                   = 1001
//         direction                  = "Inbound"
//         access                     = "Allow"
//         protocol                   = "Tcp"
//         source_port_range          = "*"
//         destination_port_range     = "22"
//         source_address_prefix      = "*"
//         destination_address_prefix = "*"
//     }

//     security_rule {
//         name                       = "WinRM"
//         priority                   = 1002
//         direction                  = "Inbound"
//         access                     = "Allow"
//         protocol                   = "Tcp"
//         source_port_range          = "*"
//         destination_port_range     = "5985"
//         source_address_prefix      = "*"
//         destination_address_prefix = "*"
//     }

//     security_rule {
//         name                       = "RDP"
//         priority                   = 1003
//         direction                  = "Inbound"
//         access                     = "Allow"
//         protocol                   = "Tcp"
//         source_port_range          = "*"
//         destination_port_range     = "3389"
//         source_address_prefix      = "*"
//         destination_address_prefix = "*"
//     }
// }

// resource "azurerm_public_ip" "db1-public-ip" {
//     name                         = "db1-public-ip"
//     location                     = azurerm_resource_group.sp2016rg.location
//     resource_group_name          = azurerm_resource_group.sp2016rg.name
//     public_ip_address_allocation = "static"
// }

// resource "azurerm_network_interface" "spfarm-db1" {
//     name                      = "network-interface-spfarm-db1"
//     location                  = azurerm_resource_group.sp2016rg.location
//     resource_group_name       = azurerm_resource_group.sp2016rg.name
//     network_security_group_id = azurerm_network_security_group.spfarm-security-group-backend.id
//     dns_servers               = ["10.10.1.18"]

//     ip_configuration {
//         name                          = "db1-ipconfiguration"
//         subnet_id                     = module.subnet-backend.id
//         public_ip_address_id          = azurerm_public_ip.db1-public-ip.id
//         private_ip_address_allocation = "static"
//         private_ip_address            = "10.10.1.17"
//     }
// }

// resource "azurerm_public_ip" "sharepoint-public-ip" {
//     name                         = "sharepoint-public-ip"
//     location                     = azurerm_resource_group.sp2016rg.location
//     resource_group_name          = azurerm_resource_group.sp2016rg.name
//     public_ip_address_allocation = "static"
// }

// resource "azurerm_network_interface" "spfarm-sharepoint" {
//     name                      = "network-interface-spfarm-sharepoint"
//     location                  = azurerm_resource_group.sp2016rg.location
//     resource_group_name       = azurerm_resource_group.sp2016rg.name
//     network_security_group_id = azurerm_network_security_group.spfarm-security-group-frontend.id
//     dns_servers               = ["10.10.1.18"]

//     ip_configuration {
//         name                                    = "sharepoint-ipconfiguration"
//         subnet_id                               = azurerm_subnet.subnet-frontend.id
//         private_ip_address_allocation           = "static"
//         private_ip_address                      = "10.10.2.18"
//     }
// }

// resource "azurerm_public_ip" "ad1-public-ip" {
//     name                         = "ad1-public-ip"
//     location                     = azurerm_resource_group.sp2016rg.location
//     resource_group_name          = azurerm_resource_group.sp2016rg.name
//     public_ip_address_allocation = "static"
// }

// resource "azurerm_network_interface" "spfarm-ad1" {
//     name                      = "network-interface-spfarm-ad1"
//     location                  = azurerm_resource_group.sp2016rg.location
//     resource_group_name       = azurerm_resource_group.sp2016rg.name
//     network_security_group_id = azurerm_network_security_group.spfarm-security-group-backend.id

//     ip_configuration {
//         name                          = "AD1-ipconfiguration"
//         subnet_id                     = module.subnet-backend.id
//         public_ip_address_id          = azurerm_public_ip.ad1-public-ip.id
//         private_ip_address_allocation = "static"
//         private_ip_address            = "10.10.1.18"
//     }
// }
