data "aws_ssm_parameter" "aviatrix_ip" {
  name            = "/aviatrix/controller/ip"
  with_decryption = true
}

data "aws_ssm_parameter" "aviatrix_username" {
  name            = "/aviatrix/controller/username"
  with_decryption = true
}

data "aws_ssm_parameter" "aviatrix_password" {
  name            = "/aviatrix/controller/password"
  with_decryption = true
}

data "azurerm_subscription" "current" {

}

data "aviatrix_transit_gateway" "transit" {
  for_each = var.transits

  gw_name    = module.mc-transit[each.key].transit_gateway.gw_name
  depends_on = [module.mc-transit]
}

data "azurerm_virtual_network" "transit_vnet" {
  for_each            = var.transits
  name                = module.mc-transit[each.key].vpc.name
  resource_group_name = module.mc-transit[each.key].vpc.resource_group
  depends_on          = [module.mc-transit]
}

data "azurerm_virtual_network" "spoke_vnet" {
  for_each            = var.spokes
  name                = module.mc-spoke[each.key].vpc.name
  resource_group_name = module.mc-spoke[each.key].vpc.resource_group
  depends_on          = [module.mc-spoke]
}