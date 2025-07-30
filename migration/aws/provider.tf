terraform {
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