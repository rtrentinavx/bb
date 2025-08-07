region = "us-west-2"

target_account_id = "060795933909"

target_role_name = "CrossAccountVPCRole"

vpcs = {
  # vpc1-vpc = {
  #   tgw_key                 = "prod"
  #   private_subnets         = []
  #   public_subnets          = []
  #   private_route_table_ids = ["rtb-02b7ac7cedebe0221", "rtb-0344bce92a57e9f9f", "rtb-093cb25be39d15363", "rtb-06d921f99ef7f7da0", "rtb-0dec62c54f227cbf6", "rtb-081e06a918257479d"]
  #   public_route_table_ids  = ["rtb-0e004e60f5af47553"]
  #   vpc_id                  = "vpc-040d3878bed24c914"
  # },
  vpc1-vpc = {
    tgw_key                 = "prod"
    private_subnets         = []
    public_subnets          = []
    private_route_table_ids = ["rtb-0dae220befe3bd03c", "rtb-029eab52306c56ee6"]
    public_route_table_ids  = ["rtb-085a9a7e3e460a2dd"]
    vpc_id                  = "vpc-0912829e6f85aefa8"
  },
  vpc3 = {
    cidr            = "10.4.0.0/24"
    tgw_key         = "infra"
    private_subnets = ["10.4.0.0/26", "10.4.0.64/26"]
    public_subnets  = ["10.4.0.128/26", "10.4.0.192/26"]
  }
}