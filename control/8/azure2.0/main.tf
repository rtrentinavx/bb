module "transit" {
  aws_ssm_region  = var.aws_ssm_region
  subscription_id = var.subscription_id
  source          = "./modules/transit"
  region          = var.region
  transits        = var.transits
  vwan_configs    = var.vwan_configs
  vnets           = var.vnets
  vwan_hubs       = var.vwan_hubs
  spokes          = var.spokes
}