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

data "aviatrix_transit_gateways" "all_transit_gws" {}