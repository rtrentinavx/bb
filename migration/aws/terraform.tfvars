region = "us-west-2"

vpcs = {
  vpc1 = {
    tgw_key                 = "prod"
    private_subnets         = []
    public_subnets          = []
    private_route_table_ids = ["rtb-078cc526746146c54"]
    public_route_table_ids  = ["rtb-076cc0a9ee80c5955"]
    vpc_id                  = "vpc-0ddfc4b8457e409f8"
  },
  vpc3 = {
    cidr            = "10.4.0.0/24"
    tgw_key         = "infra"
    private_subnets = ["10.4.0.0/26", "10.4.0.64/26"]
    public_subnets  = ["10.4.0.128/26", "10.4.0.192/26"]
  }
}