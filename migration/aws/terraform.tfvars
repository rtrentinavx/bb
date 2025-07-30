aws_ssm_region = "us-east-1"

region = "us-west-2"

vpcs = {
  vpc1 = {
    cidr            = "10.2.0.0/24"
    tgw_key         = "prod"
    private_subnets = ["10.2.0.0/26", "10.2.0.64/26"]
    public_subnets  = ["10.2.0.128/26", "10.2.0.192/26"]
  },
  vpc2 = {
    cidr            = "10.3.0.0/24"
    tgw_key         = "non-prod"
    private_subnets = ["10.3.0.0/26", "10.3.0.64/26"]
    public_subnets  = ["10.3.0.128/26", "10.3.0.192/26"]
  }
  vpc3 = {
    cidr            = "10.4.0.0/24"
    tgw_key         = "infra"
    private_subnets = ["10.4.0.0/26", "10.4.0.64/26"]
    public_subnets  = ["10.4.0.128/26", "10.4.0.192/26"]
  }
}