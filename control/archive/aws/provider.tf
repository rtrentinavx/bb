terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "3.2.2"
    }
  }
  # cloud {
  #   organization = "lab-test-avx"
  #   workspaces {
  #     name = "aws"
  #   }
  # }
}

provider "aws" {
  alias  = "ssm"
  region = var.aws_ssm_region
}

provider "aws" {
  region = var.region
}

provider "aviatrix" {
  controller_ip           = data.aws_ssm_parameter.aviatrix_ip.value
  username                = data.aws_ssm_parameter.aviatrix_username.value
  password                = data.aws_ssm_parameter.aviatrix_password.value
  skip_version_validation = false
}