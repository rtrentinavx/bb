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

data "http" "controller_login" {
  url      = "https://${data.aws_ssm_parameter.aviatrix_ip.value}/v2/api"
  insecure = true
  method   = "POST"
  request_headers = {
    "Content-Type" = "application/json"
  }
  request_body = jsonencode({
    action   = "login"
    username = data.aws_ssm_parameter.aviatrix_username.value
    password = data.aws_ssm_parameter.aviatrix_password.value
  })
  retry {
    attempts     = 5
    min_delay_ms = 1000
  }
  lifecycle {
    postcondition {
      condition     = jsondecode(self.response_body)["return"]
      error_message = "Failed to login to the controller: ${jsondecode(self.response_body)["reason"]}"
    }
  }
}

data "aviatrix_transit_gateways" "all_transit_gws" {}

data "aviatrix_spoke_gateways" "all_spoke_gws" {}

data "external" "aviatrix_connections" {
  program = ["bash", "-c", <<EOT
    curl -k -X POST https://${data.aws_ssm_parameter.aviatrix_ip.value}/v2/api \
      -H "Content-Type: application/json" \
      -d '{"action": "list_site2cloud", "CID": "${jsondecode(data.http.controller_login.response_body)["CID"]}"}' \
      | jq -c '{"result": .results | tojson}'
  EOT
  ]
  depends_on = [data.http.controller_login]
}