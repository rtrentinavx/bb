terraform {
  # cloud {
  #   organization = "lab-test-avx"
  #   workspaces {
  #     name = "aws"
  #   }
  # }
}

provider "aws" {
  region = var.region
}