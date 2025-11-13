region                   = "ca-central-1"
access_account_name      = "rvb-dev-aws-acc"
account_email            = "praveen.bomma@rubrik.com"
controller_admin_email   = "praveen.bomma@rubrik.com"
controller_name          = "rvb-lab-controller"
controller_instance_type = "t3.2xlarge"
copilot_instance_type    = "m5.2xlarge"
copilot_name             = "rvb-lab-copilot"
incoming_ssl_cidrs       = ["10.0.0.0/8", "172.16.0.0/12", "12.202.14.107/32", "50.231.3.67/32"]
controlplane_subnet_cidr = "10.85.0.0/26"
controlplane_vpc_cidr    = "10.85.0.0/25"
copilot_data_volume_size = "2000"
aws_ssm_region = "us-west-2"
module_config = {
  account_onboarding        = true
  controller_deployment     = true
  controller_initialization = true
  copilot_deployment        = true
  copilot_initialization    = true
  iam_roles                 = false # set to false when the aviatrix roles already exist
}
tags = {
  "purpose" = "Aviatrix-controlplane"
  "owner" = "network@rubrik.com"
  "rk_project" = "it-neteng"
  "deployedby" = "terraform"
}