module "transit" {
  aws_ssm_region = var.aws_ssm_region
  source         = "./modules/transit"
  hub_project_id = var.hub_project_id
  ncc_hubs       = var.ncc_hubs
  transits       = var.transits
  spokes         = var.spokes
}