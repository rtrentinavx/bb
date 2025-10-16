resource "terracurl_request" "aviatrix_firenet_firewalls" {
  name            = "aviatrix_firenet_firewalls"
  url             = "https://${data.aws_ssm_parameter.aviatrix_ip.value}/v2/api"
  method          = "GET"
  skip_tls_verify = true
  request_body = jsonencode({
    action = "list_firenet",
    CID    = jsondecode(data.http.controller_login.response_body)["CID"],
  })
  headers = {
    "Content-Type" = "application/json"
  }
  response_codes = [200]
  depends_on     = [data.http.controller_login]

  destroy_url    = var.destroy_url
  destroy_method = "GET"

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to list FireNet firewall instances: ${jsondecode(self.response)["reason"]}"
    }
    ignore_changes = all
  }
}