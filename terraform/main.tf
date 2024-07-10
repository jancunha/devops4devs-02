module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name            = "nht-vpc"
  cidr            = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/nht-eks" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/nht-eks" = "shared"
    "kubernetes.io/role/elb"        = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/nht-eks"   = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = "nht-eks"
  cluster_version = "1.27"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.micro"]
    }
  }
}