provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "ssm"
  region = var.aws_ssm_region
}

terraform { 
  cloud { 
    hostname = "tfe.rubrik.com" 
    organization = "techops" 

    workspaces { 
      name = "avx-dev-controller-copilot" 
    } 
  } 
}