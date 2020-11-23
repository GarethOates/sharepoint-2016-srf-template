resource "azurerm_virtual_network" "spfarmstaging-vnet" {
    name                = "spfarm_staging_network"
    address_space       = ["10.10.0.0/16"]
    location            = azurerm_resource_group.sp2016rg.location
    resource_group_name = azurerm_resource_group.sp2016rg.name
}

resource "azurerm_subnet" "backendsubnet" {
    name                 = "spfarm-subnet-backend"
    address_prefixes     = ["10.10.1.0/24"]
    virtual_network_name = azurerm_virtual_network.spfarmstaging-vnet.name
    resource_group_name  = azurerm_resource_group.sp2016rg.name
}

resource "azurerm_subnet" "frontendsubnet" {
    name                 = "spfarm-subnet-frontend"
    address_prefixes     = ["10.10.2.0/24"]
    virtual_network_name = azurerm_virtual_network.spfarmstaging-vnet.name
    resource_group_name  = azurerm_resource_group.sp2016rg.name
}

resource "azurerm_subnet" "gatewaysubnet" {
    name                 = "GatewaySubnet"
    address_prefixes     = ["10.10.3.0/24"]
    virtual_network_name = azurerm_virtual_network.spfarmstaging-vnet.name
    resource_group_name  = azurerm_resource_group.sp2016rg.name
}

resource "azurerm_public_ip" "gateway-public-ip" {
    name                         = "GatewayPublicIp"
    location                     = azurerm_resource_group.sp2016rg.location
    resource_group_name          = azurerm_resource_group.sp2016rg.name
    allocation_method            = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "sharepointgateway" {
    name                = "sharepointgateway"
    location            = azurerm_resource_group.sp2016rg.location
    resource_group_name = azurerm_resource_group.sp2016rg.name
    type                = "Vpn"
    sku                 = "VpnGw1"

    ip_configuration {
        subnet_id            = azurerm_subnet.gatewaysubnet.id
        public_ip_address_id = azurerm_public_ip.gateway-public-ip.id
    }

    vpn_client_configuration {
        address_space        = ["192.168.0.0/16"]
        vpn_client_protocols = ["OpenVPN"]

        aad_tenant           = format("https://login.microsoftonline.com/%s/", data.azurerm_client_config.current.tenant_id)
        aad_audience         = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
        aad_issuer           = format("https://sts.windows.net/%s/", data.azurerm_client_config.current.tenant_id)
    }
}

resource "azurerm_network_interface" "spfarm-db1" {
    name                      = "network-interface-spfarm-db1"
    location                  = azurerm_resource_group.sp2016rg.location
    resource_group_name       = azurerm_resource_group.sp2016rg.name
    dns_servers               = ["10.10.1.18", "1.1.1.1"]

    ip_configuration {
        name                          = "db1-ipconfiguration"
        subnet_id                     = azurerm_subnet.backendsubnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.10.1.17"
    }
}

resource "azurerm_network_interface" "spfarm-sharepoint" {
    name                      = "network-interface-spfarm-sharepoint"
    location                  = azurerm_resource_group.sp2016rg.location
    resource_group_name       = azurerm_resource_group.sp2016rg.name
    dns_servers               = ["10.10.1.18", "1.1.1.1"]

    ip_configuration {
        name                                    = "sharepoint-ipconfiguration"
        subnet_id                               = azurerm_subnet.frontendsubnet.id
        private_ip_address_allocation           = "Static"
        private_ip_address                      = "10.10.2.19"
    }
}

resource "azurerm_network_interface" "spfarm-ad1" {
    name                      = "network-interface-spfarm-ad1"
    location                  = azurerm_resource_group.sp2016rg.location
    resource_group_name       = azurerm_resource_group.sp2016rg.name

    ip_configuration {
        name                          = "AD1-ipconfiguration"
        subnet_id                     = azurerm_subnet.backendsubnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.10.1.18"
    }
}
