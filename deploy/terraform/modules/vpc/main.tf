variable "env" {
  default = ""
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc_01" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-${var.env}"
  }
}

resource "aws_subnet" "subnet_01" {
  availability_zone = data.aws_availability_zones.available.names[0]

  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name                            = "subnet-01-${var.env}"
    "kubernetes.io/cluster/eks-dev" = "shared"
  }
}

resource "aws_subnet" "subnet_02" {
  availability_zone       = data.aws_availability_zones.available.names[1]
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name                            = "subnet-02-${var.env}"
    "kubernetes.io/cluster/eks-dev" = "shared"
  }
}

output "vpc_01_id" {
  value = aws_vpc.vpc_01.id
}

output "subnet_01_id" {
  value = aws_subnet.subnet_01.id
}

output "subnet_02_id" {
  value = aws_subnet.subnet_02.id
}

resource "aws_internet_gateway" "internet_gw_01" {
  vpc_id = aws_vpc.vpc_01.id
}

resource "aws_eip" "eip_01" {
  vpc = true

  depends_on = [
  aws_internet_gateway.internet_gw_01]
}

resource "aws_route_table" "route_table_01" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw_01.id
  }

  tags = {
    Name = "aws_route_table"
  }
}
