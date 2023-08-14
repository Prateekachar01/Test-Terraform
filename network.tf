# Creating the VPC

resource "aws_vpc" "vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "VPC-017" #VPC name
  }
}

#Creating the IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "IGW-017" # Internet Gateway name
  }
}

# Find available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

#  Creating 2 Public Subnets in each AZ
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.${1 + count.index}.0/24"  # CIDR calculation
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
tags = {
    Name = "PublicSubnet-017-${count.index + 1}"
  }
}

# Creating an elastic IP
resource "aws_eip" "eip" {
  domain = "vpc"
}

#Creating the NGW

resource "aws_nat_gateway" "network_interface" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.0.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "NGW-017" # NAT Gateway name
  }
}

# Creating 2 Private Subnets in each AZ
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.${10 + count.index * 4}.0/24"  # CIDR calculation
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
tags = {
    Name = "PrivateSubnet-017-${count.index + 1}"
  }
}

# Creating a public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
tags = {
    Name = "PublicRouteTables-017"
  }
}

# Associating public subnets to public route table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Creating a Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.network_interface.id
  }
tags = {
    Name = "PrivateRouteTables-017"
  }
}
# Associating private subnets to private route table
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

