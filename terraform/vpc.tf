resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"

  # required for EKS
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

