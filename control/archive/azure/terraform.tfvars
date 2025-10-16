aws_ssm_region  = "us-east-1"

region          = "West US 2"

subscription_id = "47ab116c-8c15-4453-b06a-3fecd09ebda9"

transits = {
  "azure-westus20-transit-vnet" = {
    cidr            = "10.1.0.0/24"
    instance_size   = "Standard_D16_v3"
    account         = "lab-test-azure"
    local_as_number = 65001
    fw_amount       = 2
    firewall_image          = "Palo Alto Networks VM-Series Flex Next-Generation Firewall BYOL"
    firewall_image_version  = "11.2.5"
    vwan_connections = [
      {
        vwan_name     = "vwan-infra"
        vwan_hub_name = "infra"
      }
    ]
  }
}

spokes = {
  "azure-spoke20-vnet" = {
    cidr            = "10.17.0.0/24"
    instance_size   = "Standard_D8_v3"
    account         = "lab-test-azure"
    local_as_number = 65002
    vwan_connections = [
      {
        vwan_name     = "wan-prod",
        vwan_hub_name = "prod"
      }
    ]
  }
}

vwan_configs = {
  "vwan-prod" = {
    location            = "East US"
    resource_group_name = "rg-vwan-prod"
    existing            = false
  }
  "vwan-infra" = {
    location            = "East US"
    resource_group_name = "rg-vwan-infra"
    existing            = false
  }
}

vwan_hubs = {
  "infra" = {
    virtual_hub_cidr = "10.2.0.0/24"
  }
  "prod" = {
    virtual_hub_cidr = "10.3.0.0/24"
  }
}

vnets = {
  # "workload1-vnet" = {
  #   cidr            = "10.4.0.0/16"
  #   private_subnets = ["10.4.1.0/24", "10.4.2.0/24"]
  #   public_subnets  = ["10.4.3.0/24", "10.4.4.0/24"]
  #   vwan_name       = "vwan-infra"
  #   vwan_hub_name   = "infra"
  # }
  # "workload2-vnet" = {
  #   resource_group_name = "rg-vnet-workload2-vnet-eastus"
  #   vwan_name           = "vwan-prod"
  #   vwan_hub_name       = "prod"
  #   existing            = true
  # }
}