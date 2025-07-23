terraform {
  cloud {
    organization = "lab-test-avx"
    workspaces {
      name = "mgmt"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "ssm"
  region = var.aws_ssm_region
}