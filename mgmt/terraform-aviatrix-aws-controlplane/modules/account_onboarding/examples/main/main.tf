# Updated on May 22, 2025 at 04:11 PM EDT
module "account_onboarding" {
  source = "./modules/account_onboarding"

  controller_public_ip      = "1.2.3.4"
  controller_admin_password = "my-password"
  access_account_name       = "aws"
  account_email             = "admin@domain.com"
}
