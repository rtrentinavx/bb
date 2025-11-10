region                   = "us-east-1"
access_account_name      = "hss-firewall"
account_email            = "NetworkEngineering@hss.edu"
controller_admin_email   = "NetworkEngineering@hss.edu"
controller_name          = "aws-ue1-aviatrix-cont"
controller_instance_type = "t3.2xlarge"
copilot_instance_type    = "m5.2xlarge"
copilot_name             = "aws-ue1-aviatrix-cop"
incoming_ssl_cidrs       = ["74.117.136.0/24"]
copilot_data_volume_size = "2000"
use_existing_vpc = true 
subnet_id = ""
vpc_id = ""
module_config = {
  account_onboarding        = true
  controller_deployment     = true
  controller_initialization = true
  copilot_deployment        = true
  copilot_initialization    = true
  iam_roles                 = true 
}
tags = {
  "deployedby" = "terraform"
}

# region                   = "us-east-1"
# access_account_name      = "lab-test-aws"
# account_email            = "rtrentin@aviatrix.com"
# controller_admin_email   = "rtrentin@aviatrix.com"
# controller_name          = "AviatrixController2"
# controller_instance_type = "t3.2xlarge"
# copilot_instance_type    = "m5.2xlarge"
# copilot_name             = "AviatrixCopilot2"
# incoming_ssl_cidrs       = ["23.124.126.28/32"]
# controlplane_subnet_cidr = "172.16.25.0/26"
# controlplane_vpc_cidr    = "172.16.25.0/25"
# copilot_data_volume_size = "2000"
# module_config = {
#   account_onboarding        = true
#   controller_deployment     = true
#   controller_initialization = true
#   copilot_deployment        = true
#   copilot_initialization    = true
#   iam_roles                 = true # set to false when the aviatrix roles already exist
# }
# tags = {
#   "deployedby" = "terraform"
# }
