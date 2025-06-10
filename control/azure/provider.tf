terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "3.2.2"
    }
  }
}
provider "aws" {

}

provider "aviatrix" {
  controller_ip           = data.aws_ssm_parameter.aviatrix_ip.value
  username                = data.aws_ssm_parameter.aviatrix_username.value
  password                = data.aws_ssm_parameter.aviatrix_password.value
  skip_version_validation = false
}

provider "azurerm" {
  subscription_id = "47ab116c-8c15-4453-b06a-3fecd09ebda9"
  features {
  }
}