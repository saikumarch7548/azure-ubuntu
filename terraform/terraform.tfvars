resource_group_name= "siemmens-demo"
location= "West Europe"
tags= {
        environment = "siemmens-assignment-tf"
    }
vm_size= "Standard_NC6s_v3"

vm_os_publisher= "Canonical"
vm_os_offer= "UbuntuServer"
vm_os_sku= "18.04-LTS"
vm_os_version= "latest"
storage_account_type = "Premium_LRS"
vm_hostname= "azuretestvm"
admin_username= "siemenstester"
sg  = {
       "ssh-global" = {
        name     = "SSH-From-global",
        port     = "22",
        ip       = "*",
        priority = "1001",
	     protocol = "TCP"
	     direction= "Inbound"
      }
	   "Inbound-port-36666" = {
        name     = "inbound-port-36666",
        port     = "36666",
        ip       = "*",
        priority = "1002"
	     protocol = "*"
	     direction= "Inbound"
      }
  }
