resource "azurerm_resource_group" "my_rg" {
  name     = var.rg_name
  location = var.location

  tags = {
    Environment = var.Environment
    Project     = var.Project
    Owner       = var.Owner
  }
}

resource "azurerm_virtual_network" "my_Vnet" {
  name                = var.my_Vnet
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.my_rg.name
}

resource "azurerm_subnet" "my_Subnet" {
  name                 = var.my_Subnet
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.my_Vnet.name
  address_prefixes     = ["10.0.2.0/27"]
}

resource "azurerm_network_security_group" "my_nsg" {
  name                = var.my_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.my_rg.name

  tags = {
    Environment = var.Environment
    Project     = var.Project
    Owner       = var.Owner
  }
}

locals {
  my_nsg_rules = {
    #"110" = "22"
    "120" = "80"
    "130" = "443"
  }
}

resource "azurerm_network_security_rule" "rules" {
  for_each = local.my_nsg_rules

  name                        = "Allow-${each.value}"
  priority                    = tonumber(each.key)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"

  resource_group_name         = azurerm_resource_group.my_rg.name
  network_security_group_name = azurerm_network_security_group.my_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "my_nsg_association" {
  subnet_id                 = azurerm_subnet.my_Subnet.id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}

resource "azurerm_public_ip" "my_pip" {
  name                = var.my_pip
  location            = var.location
  resource_group_name = azurerm_resource_group.my_rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_lb" "my_lb" {
  name                = "Kyndryl-LB"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.my_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.my_lb.id
  name            = "bkyndryl-ackend-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "backend_assoc" {
  count = length(var.VM_NAMES)

  network_interface_id    = azurerm_network_interface.my_nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

resource "azurerm_lb_rule" "http_rule" {
  loadbalancer_id                = azurerm_lb.my_lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"

  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.backend_pool.id
  ]

  probe_id = azurerm_lb_probe.http_probe.id
}

resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id = azurerm_lb.my_lb.id
  name            = "http-probe"
  port            = 80
}


resource "azurerm_network_interface" "my_nic" {
  count = length(var.VM_NAMES)

  name                = "${var.my_nic}-${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

/*
resource "azurerm_subnet" "Bastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.my_Vnet.name
    address_prefixes     = ["10.0.1.0/27"]
}

resource "azurerm_public_ip" "BastionPIP" {
  name                = "BastionPIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "BastionHost" {
  name                = "bastionhost"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.Bastionsubnet.id
    public_ip_address_id = azurerm_public_ip.BastionPIP.id
  }
}
*/

resource "azurerm_linux_virtual_machine" "my_VM" {
  count = length(var.VM_NAMES)

  name                = "${var.my_VM}-${var.VM_NAMES[count.index]}"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = var.location

  size =var.instance_type["Testing"]
  admin_username = var.username
  admin_password = var.password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.my_nic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "9-lvm"
    version   = "latest"
  }

  tags = {
    Environment = var.Environment
    Project     = var.Project
    Owner       = var.Owner
  }
  custom_data = filebase64("${path.module}/app/app.sh")
}


/*
resource "azurerm_windows_virtual_machine" "Windows_VM" {
  count               = var.vm_count
  name                = "${var.Windows_VM}${count.index + 1}"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.my_nic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  custom_data = filebase64("${path.module}/app/app.ps1")
  
}
*/


