data "aws_ssm_parameter" "aviatrix_password" {
  name            = "/aviatrix/controller/dev_password"
  with_decryption = true
  provider = aws.ssm
}

data "aws_ssm_parameter" "aviatrix_customer_id" {
  name            = "/aviatrix/controller/customer_id"
  with_decryption = true
  provider = aws.ssm
}
