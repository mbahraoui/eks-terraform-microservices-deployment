resource "aws_subnet" "public_1" {
  vpc_id            = var.vpc_id
  cidr_block        = "192.168.0.0/18"
  availability_zone = "eu-west-3a"

  map_public_ip_on_launch = true

  tags = {
    Name                        = "public-eu-west-3a"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = var.vpc_id
  cidr_block        = "192.168.64.0/18"
  availability_zone = "eu-west-3b"

  map_public_ip_on_launch = true

  tags = {
    Name                        = "public-eu-west-3b"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = var.vpc_id
  cidr_block        = "192.168.128.0/18"
  availability_zone = "eu-west-3a"

  tags = {
    Name                              = "private-eu-west-3a"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = var.vpc_id
  cidr_block        = "192.168.192.0/18"
  availability_zone = "eu-west-3b"

  tags = {
    Name                              = "private-eu-west-3b"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw1.id
  }

  tags = {
    Name = "private1"
  }
}

resource "aws_route_table" "private2" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw2.id
  }

  tags = {
    Name = "private2"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private2.id
}

resource "aws_eip" "nat1" {
  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "nat2" {
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "gw1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "NAT 1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "gw2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "NAT 2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}
