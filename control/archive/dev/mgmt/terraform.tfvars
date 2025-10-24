region                   = "ca-west-1"
access_account_name      = "rvb-dev-aws-acc"
account_email            = "praveen.bomma@rubrik.com"
controller_admin_email   = "praveen.bomma@rubrik.com"
controller_name          = "rvb-lab-controller"
controller_instance_type = "t3.2xlarge"
copilot_instance_type    = "m5.2xlarge"
copilot_name             = "rvb-lab-copilot"
incoming_ssl_cidrs       = ["0.0.0.0/0"]
controlplane_subnet_cidr = "10.85.0.0/26"
controlplane_vpc_cidr    = "10.85.0.0/25"
copilot_data_volume_size = "2000"
module_config = {
  account_onboarding        = true
  controller_deployment     = true
  controller_initialization = true
  copilot_deployment        = true
  copilot_initialization    = true
  iam_roles                 = true # set to false when the aviatrix roles already exist
}
tags = {
  "deployedby" = "terraform"
}