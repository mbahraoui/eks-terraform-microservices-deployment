resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"

  # required for EKS
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

module "mysubnets" {
  source = "./modules/subnets"
  vpc_id = aws_vpc.main.id
}

module "myeks-cluster" {
  source = "./modules/eks"
  public_1_id=module.mysubnets.subnet_public_1.id
  public_2_id=module.mysubnets.subnet_public_2.id
  private_1_id=module.mysubnets.subnet_private_1.id
  private_2_id=module.mysubnets.subnet_private_2.id
}

