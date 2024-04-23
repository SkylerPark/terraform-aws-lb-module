locals {
  availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnet_count  = 2
  private_subnet_count = 2

  nat_gateway_count        = local.single_nat_gateway ? 1 : local.multi_per_az_nat_gateway ? length(local.availability_zones) : 0
  multi_per_az_nat_gateway = true
  single_nat_gateway       = false
}

module "vpc" {
  source = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/vpc/?ref=tags/1.1.0"
  name   = "parksm-test"
  ipv4_cidrs = [
    {
      cidr = "10.70.0.0/16"
    }
  ]
  internet_gateway = {
    enabled = true
  }
}

module "public_subnet_group" {
  source = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/subnet-group/?ref=tags/1.1.0"
  name   = "parksm-test"
  vpc_id = module.vpc.id
  subnets = {
    for idx in range(local.public_subnet_count) : format("parksm-test-public-subnet-0%s", (idx + 1)) => {
      availability_zone = local.availability_zones[idx % length(local.availability_zones)]
      ipv4_cidr         = cidrsubnet("10.70.0.0/16", 8, 10 + idx + 1)
    }
  }
}

module "private_subnet_group" {
  source = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/subnet-group/?ref=tags/1.1.0"
  name   = "parksm-test"
  vpc_id = module.vpc.id
  subnets = {
    for idx in range(local.private_subnet_count) : format("parksm-test-private-subnet-0%s", (idx + 1)) => {
      availability_zone = local.availability_zones[idx % length(local.availability_zones)]
      ipv4_cidr         = cidrsubnet("10.70.0.0/16", 8, 30 + idx + 1)
    }
  }
}

module "eip" {
  source = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/elastic-ip/?ref=tags/1.1.0"
  count  = local.nat_gateway_count
  name   = "parksm-natgw-${local.availability_zones[count.index]}"
}

module "nat_gateway" {
  source = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/nat-gateway/?ref=tags/1.1.0"
  count  = local.nat_gateway_count
  name   = "parksm-natgw-${local.availability_zones[count.index]}"

  subnet_id = module.public_subnet_group.ids[count.index]

  primary_ip_assignment = {
    elastic_ip = module.eip[count.index].id
  }
}

module "public_route_table" {
  source  = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/route-table/?ref=tags/1.1.0"
  name    = "parksm-public-rt"
  vpc_id  = module.vpc.id
  subnets = module.public_subnet_group.ids

  ipv4_routes = [
    {
      destination = "0.0.0.0/0"
      target = {
        type = "INTERNET_GATEWAY"
        id   = module.vpc.internet_gateway.id
      }
    }
  ]

  propagating_vpn_gateways = []
}

module "private_route_table" {
  source = "git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/route-table/?ref=tags/1.1.0"
  count  = local.nat_gateway_count
  name   = "parksm-private-rt-${local.availability_zones[count.index]}"
  vpc_id = module.vpc.id
  subnets = [
    for subnet in module.private_subnet_group.subnets_by_az[local.availability_zones[count.index]] :
    subnet.id
  ]

  ipv4_routes = [
    {
      destination = "0.0.0.0/0"
      target = {
        type = "NAT_GATEWAY"
        id   = module.nat_gateway[count.index].id
      }
    }
  ]

  propagating_vpn_gateways = []
}


