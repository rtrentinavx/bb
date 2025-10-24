# Updated on May 22, 2025 at 04:11 PM EDT
#Login, obtain CID.
data "http" "controller_login" {
  url      = "https://${var.controller_public_ip}/v2/api"
  insecure = true
  method   = "POST"
  request_headers = {
    "Content-Type" = "application/json"
  }
  request_body = jsonencode({
    action   = "login",
    username = var.controller_admin_username,
    password = var.controller_admin_password,
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

data "aws_caller_identity" "current" {}

resource "terracurl_request" "aws_access_account" {
  name            = "aws_access_account"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  timeout         = 300
  request_body = jsonencode({
    action             = "setup_account_profile",
    CID                = jsondecode(data.http.controller_login.response_body)["CID"],
    account_name       = var.access_account_name,
    cloud_type         = "1",
    account_email      = var.account_email,
    aws_account_number = data.aws_caller_identity.current.account_id,
    aws_iam            = true,
    aws_role_ec2       = format("arn:aws:iam::%s:role/%s", data.aws_caller_identity.current.account_id, var.aws_role_ec2)
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  # Disabled destroy lifecycle, as terracurl cannot cope with dynamic credentials at this time. See https://github.com/devops-rob/terraform-provider-terracurl/issues/83.

  destroy_url    = var.destroy_url
  destroy_method = "GET"

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to create access account: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [
    data.http.controller_login,
  ]
}
