aws_ssw_region = "us-east-1"
domains        = ["infra", "prod", "non-prod"]
connection_policy = [
  { source = "infra", target = "prod" },
  { source = "infra", target = "non-prod" }
]