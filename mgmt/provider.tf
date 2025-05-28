# Updated on May 22, 2025 at 04:11 PM EDT
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