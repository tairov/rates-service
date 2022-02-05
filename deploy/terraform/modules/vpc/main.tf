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
  vpc_id     = aws_vpc.vpc_01.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet-01-${var.env}"
  }
}

resource "aws_subnet" "subnet_02" {
  vpc_id     = aws_vpc.vpc_01.id
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
