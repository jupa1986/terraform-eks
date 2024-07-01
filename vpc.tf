provider "aws" {
  region = var.region
}

locals {
  cluster_name = "eks-1986"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "guru-vpc"

  cidr = "10.25.0.0/16"
  azs  = ["${var.region}a", "${var.region}b", "${var.region}a", "${var.region}b"]

  private_subnets = ["10.25.1.0/24", "10.25.2.0/24",  "10.25.96.0/19", "10.25.128.0/19"]

  public_subnets  = ["10.25.160.0/19", "10.25.192.0/19"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"  
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}
