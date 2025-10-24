# Updated on May 22, 2025 at 04:11 PM EDT
terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "3.2.1"
    }
  }
  # cloud {
  #   organization = "lab-test-avx"
  #   workspaces {
  #     name = "gcp"
  #   }
  # }
}

provider "aws" {
  alias  = "ssm"
  region = var.aws_ssm_region

}

provider "aviatrix" {
  controller_ip           = data.aws_ssm_parameter.aviatrix_ip.value
  username                = data.aws_ssm_parameter.aviatrix_username.value
  password                = data.aws_ssm_parameter.aviatrix_password.value
  skip_version_validation = false
}

provider "google" {

}

# $ export AVIATRIX_USERNAME="admin"
# $ export AVIATRIX_PASSWORD="password"