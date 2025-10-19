aws_ssw_region = "us-west-2"
domains        = ["infra", "prod", "non-prod", "ai-1"]
connection_policy = [
  { source = "infra", target = "prod" },
  { source = "infra", target = "non-prod" }
]