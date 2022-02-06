variable "env" {
  default = ""
}

resource "aws_vpc" "vpc_01" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-${var.env}"
  }
}

resource "aws_subnet" "subnet_01" {
  vpc_id = aws_vpc.vpc_01.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet-01-${var.env}"
  }
}

resource "aws_subnet" "subnet_02" {
  vpc_id = aws_vpc.vpc_01.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "subnet-02-${var.env}"
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

resource "aws_nat_gateway" "natgw_01" {
  allocation_id = aws_eip.eip_01.id
  subnet_id = aws_subnet.subnet_01.id

  tags = {
    Name = "vpc_01_natgw_01_${var.env}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.internet_gw_01]
}

resource "aws_route_table" "route_table_01" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw_01.id
  }

  tags = {
    Name = "aws_route_table"
  }
}
