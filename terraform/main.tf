# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "vm" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"
    tags     = "${var.tags}"
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.location}"
    resource_group_name = azurerm_resource_group.vm.name
    tags                = "${var.tags}"
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.vm.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "${var.location}"
    resource_group_name          = azurerm_resource_group.vm.name
    allocation_method            = "Dynamic"
    tags                         = "${var.tags}" 
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup22"
    location            = "${var.location}"
    resource_group_name = azurerm_resource_group.vm.name
    tags                = "${var.tags}" 
}

resource "azurerm_network_security_rule" "custom_rules" {
  direction                   = each.value.direction
  access                      = "Allow"
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.vm.name}"
  network_security_group_name = "${azurerm_network_security_group.myterraformnsg.name}"
  for_each                    = var.sg
  destination_port_range      = each.value.port
  source_address_prefix       = each.value.ip
  name                        = each.value.name
  priority                    = each.value.priority
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "${var.location}"
    resource_group_name       = azurerm_resource_group.vm.name
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }
    tags                              = "${var.tags}"
}


# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.vm.name
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.vm.name
    location                    = "${var.location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    tags                        = "${var.tags}"
}

# Create virtual machine
resource "azurerm_virtual_machine" "vm-ubuntu" {
    name                  = "myVM"
    location              = "${var.location}"
    resource_group_name   = azurerm_resource_group.vm.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    vm_size               = "${var.vm_size}"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "${var.vm_os_publisher}"
        offer     = "${var.vm_os_offer}"
        sku       = "${var.vm_os_sku}"
        version   = "${var.vm_os_version}"
    }

    os_profile {
        computer_name  = "${var.vm_hostname}"
        admin_username = "${var.admin_username}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${var.admin_username}/.ssh/authorized_keys"
            key_data = "${file("${var.ssh_key}")}"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }
    tags            = "${var.tags}"
}
