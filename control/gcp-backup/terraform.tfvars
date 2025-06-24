hub_project_id = "rtrentin-01"
transits = [
  {
    access_account_name = "lab-test-gcp"
    gw_name             = "gcp-transit-central"
    project_id          = "rtrentin-01"
    region              = "us-central1"
    zone                = "us-central1-b"
    ha_zone             = "us-central1-c"
    name                = "transit-central"
    vpc_cidr            = "10.1.254.0/23"
    gw_size             = "n2-highcpu-8"
    bgp_lan_subnets = {
      interconnect = "10.1.0.0/24"
      infra        = "10.1.1.0/24"
      non-prod     = "10.1.2.0/24"
      prod         = "10.1.3.0/24"
    }
    cloud_router_asn = 65500
    aviatrix_gw_asn  = 65511
  }
]
spokes = [
  {
    vpc_name   = "rbk-infra"
    project_id = "rtrentin-01"
    ncc_hub    = "infra"
  }
]