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

data "aws_vpcs" "all_vpcs" {}

data "aws_vpc" "vpcs" {
  for_each = toset(data.aws_vpcs.all_vpcs.ids)
  id       = each.value
}

data "aws_subnets" "subnets" {
  for_each = toset(data.aws_vpcs.all_vpcs.ids)
  filter {
    name   = "vpc-id"
    values = [each.value]
  }
}

data "aws_subnet" "subnet_details" {
  for_each = toset(flatten([for vpc_id in data.aws_vpcs.all_vpcs.ids : data.aws_subnets.subnets[vpc_id].ids]))
  id       = each.value
}