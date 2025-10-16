module "transit" {
  aws_ssm_region   = var.aws_ssm_region
  source           = "./modules/transit"
  region           = var.region
  transits         = var.transits
  tgws             = var.tgws
  external_devices = var.external_devices
}