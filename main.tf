terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.77.0"
    }
  }
  backend "remote" {
    organization = "k-nikola"

    workspaces {
      name = "terraform-ansible-azure"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {

  }
}
# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.azure_region

  tags = {
    environment = var.environment
  }
}
# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = var.address_space
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    environment = var.environment
  }
}
# Create a subnet 
resource "azurerm_subnet" "subnet" {
  name                 = var.virtual_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.address_prefixes
}
# Create Public IP
resource "azurerm_public_ip" "publicip" {
  name                = var.public_ip_name
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags = {
    environment = var.environment
  }
}
# Create a network security group
resource "azurerm_network_security_group" "netsecgroup" {
  name                = var.network_security_group_name
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.rg.name
  # Create security rule to allow SSH into the VM
  security_rule = [{
    access                                     = "Allow"
    description                                = "Enable SSH into VM"
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = 22
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "allow_ssh"
    priority                                   = 105
    protocol                                   = "TCP"
    source_address_prefix                      = "${var.ssh_address}"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
    }, {
    access                                     = "Allow"
    description                                = "Allow web access"
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = 80
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "allow_web"
    priority                                   = 106
    protocol                                   = "TCP"
    source_address_prefix                      = "*"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }]
  tags = {
    environment = var.environment
  }
}
# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = var.network_interface_name
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "myNICConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
  tags = {
    environment = var.environment
  }
}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "NIC-NSG" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.netsecgroup.id
}

resource "azurerm_ssh_public_key" "example" {
  name                = "ssh_public_key"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_region
  public_key          = file("~/.ssh/id_rsa.pub")
}
# Create VM instance
resource "azurerm_virtual_machine" "vm" {
  name                  = "ubuntu_vm2"
  location              = var.azure_region
  resource_group_name   = azurerm_resource_group.rg.name
  vm_size               = "Standard_B2s"
  network_interface_ids = [azurerm_network_interface.nic.id]
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  #Delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true
  #Delete the data disk automatically when deleting the VM
  delete_data_disks_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_profile {
    computer_name  = "ubuntu${var.computer_name}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
  tags = {
    environment = var.environment
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.publicip.ip_address
      user        = var.admin_username
      private_key = file("~/.ssh/id_rsa")
      timeout     = "2m"
      agent       = false
    }
    inline = ["echo 'connection via ssh ready'"]
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${azurerm_public_ip.publicip.ip_address}, -u ${var.admin_username} --private-key='~/.ssh/id_rsa' ansible/pb.yml"
  }
}
