aws_ssw_region = "us-east-1"
connection_policy = [
  { source = "infra", target = "prod" },
  { source = "infra", target = "non-prod" },
  { source = "domain-a", target = "domain-b" }
]