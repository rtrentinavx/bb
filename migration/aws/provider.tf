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

provider "aws" {
  alias  = "target"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.target_account_id}:role/${var.target_role_name}"
  }
}