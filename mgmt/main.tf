# Updated on May 22, 2025 at 04:11 PM EDT

module "control_plane" {
  source                    = "./terraform-aviatrix-aws-controlplane/"
  controller_name           = var.controller_name
  copilot_name              = var.copilot_name
  incoming_ssl_cidrs        = var.incoming_ssl_cidrs
  controller_admin_email    = var.controller_admin_email
  controller_admin_password = var.controller_admin_password
  controlplane_subnet_cidr  = var.controlplane_subnet_cidr
  controlplane_vpc_cidr     = var.controlplane_vpc_cidr
  account_email             = var.account_email
  access_account_name       = var.access_account_name
  customer_id               = var.customer_id
  copilot_data_volume_size  = var.copilot_data_volume_size
  use_existing_vpc          = var.use_existing_vpc
  vpc_id                    = var.vpc_id
  subnet_id                 = var.subnet_id
  controller_version        = var.controller_version
  module_config             = var.module_config
  controller_instance_type  = var.controller_instance_type
  copilot_instance_type     = var.copilot_instance_type
}
