
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.19"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # Cost optimization: Single NAT Gateway for all private subnets
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  # Enable DNS support for EKS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Internet Gateway for public subnets
  create_igw = true

  # Tags for EKS cluster discovery
  public_subnet_tags = merge(var.common_tags, {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })


  tags = var.common_tags
}
