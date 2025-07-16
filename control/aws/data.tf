
data "aws_ssm_parameter" "aviatrix_ip" {
  provider        = aws.ssm
  name            = "/aviatrix/controller/ip"
  with_decryption = true
}

data "aws_ssm_parameter" "aviatrix_username" {
  provider        = aws.ssm
  name            = "/aviatrix/controller/username"
  with_decryption = true
}

data "aws_ssm_parameter" "aviatrix_password" {
  provider        = aws.ssm
  name            = "/aviatrix/controller/password"
  with_decryption = true
}

data "aws_ec2_transit_gateway" "tgw" {
  depends_on = [aws_ec2_transit_gateway.tgw]
  for_each   = { for k, v in var.tgws : k => v if !v.create_tgw }

  filter {
    name   = "options.amazon-side-asn"
    values = [each.value.amazon_side_asn]
  }
  filter {
    name   = "tag:Name"
    values = [each.key]
  }
}

data "aws_subnet" "gw_subnet" {
  for_each   = var.transits
  depends_on = [module.mc-transit]

  vpc_id = module.mc-transit[each.key].vpc.vpc_id

  filter {
    name   = "tag:Name"
    values = ["aviatrix-${local.stripped_names[each.key]}"]
  }
}

data "aws_subnet" "hagw_subnet" {
  for_each   = var.transits
  depends_on = [module.mc-transit]

  vpc_id = module.mc-transit[each.key].vpc.vpc_id

  filter {
    name   = "tag:Name"
    values = ["aviatrix-${local.stripped_names[each.key]}-hagw"]
  }
}

data "aws_route_table" "route_table" {
  for_each = var.transits

  subnet_id = data.aws_subnet.gw_subnet[each.key].id
}

data "aws_availability_zones" "available" {
  state = "available"
}