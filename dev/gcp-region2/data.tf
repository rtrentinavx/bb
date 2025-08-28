data "aws_ssm_parameter" "aviatrix_ip" {
  name            = "/aviatrix/controller/ip"
  with_decryption = true
  provider        = aws.ssm
}

data "aws_ssm_parameter" "aviatrix_username" {
  name            = "/aviatrix/controller/username"
  with_decryption = true
  provider        = aws.ssm
}

data "aws_ssm_parameter" "aviatrix_password" {
  name            = "/aviatrix/controller/password"
  with_decryption = true
  provider        = aws.ssm
}

data "aviatrix_transit_gateway" "transit_gws" {
  for_each = { for transit in var.transits : transit.gw_name => transit if module.mc_transit[transit.gw_name].transit_gateway.gw_name != "" }

  gw_name = each.value.gw_name
}