data "aws_ssm_parameter" "aviatrix_ip" {
  provider        = aws.ssm
  name            = "dev_aviatrix_ip"
  with_decryption = true
}

data "aws_ssm_parameter" "aviatrix_username" {
  provider        = aws.ssm
  name            = "dev_aviatrix_username"
  with_decryption = true
}

data "aws_ssm_parameter" "aviatrix_password" {
  provider        = aws.ssm
  name            = "dev_aviatrix_password"
  with_decryption = true
}
data "aviatrix_transit_gateway" "transit_gws" {
  for_each = { for transit in var.transits : transit.gw_name => transit if module.mc_transit[transit.gw_name].transit_gateway.gw_name != "" }

  gw_name = each.value.gw_name
}