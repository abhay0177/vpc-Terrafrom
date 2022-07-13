provider "aws" {
   region = "us-east-1"
}


#create vpc
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames           = "true"
  enable_dns_support             = "true"
  enable_classiclink_dns_support = "true"

  tags = {
    Name = "main"
  }
}


#public subnet
resource "aws_subnet" "dev-public-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"

  tags = {
    Name = "dev-public-1"
  }
}

resource "aws_subnet" "dev-public-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"

  tags = {
    Name = "dev-public-2"
  }
}


#private subnet
resource "aws_subnet" "dev-private-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-1b"

  tags = {
    Name = "dev-private-1"
  }
}

resource "aws_subnet" "dev-private-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-1b"

  tags = {
    Name = "dev-private-2"
  }
}


#internet gateway
resource "aws_internet_gateway" "dev-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


#route table for IG
resource "aws_route_table" "example1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-gw.id
  }

  tags = {
    Name = "example1"
  }
}


#association of route table for public subnets
resource "aws_route_table-association" "dev-public-1-a" {
  subnet_id = aws_subnet.dev-public-1.id
  route_table_id = aws_route_table.example1.id
}

resource "aws_route_table_association" "dev-public-2-a" {
  subnet_id = aws_subnet.dev-public-2.id
  route_table_id = aws_route_table.example1.id
}


#route table default
resource "aws_default_route_table" "example2"{
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
   Name = "example2"
 }
}


#association of route table for private subnets
resource "aws_route_table_association" "dev-private-1-b" {
  subnet_id = aws_subnet.dev-private-1.id
  route_table_id = aws_vpc.main.default_route_table_id
}

resource "aws_route_table_association" "dev-private-2-b" {
  subnet_id = aws_subnet.dev-private-2.id
  route_table_id = aws_vpc.main.default_route_table_id
}


#Create Elastic ip
resource "aws_eip" "eip"{
  vpc = true
  depends_on = [aws_internet_gateway.dev-gw]
  tags = {
  Name = "NAT gateway eip"
}
}


#NAT gateway
resource "aws_nat_gateway" "ngw" {
  connectivity_type = "public"
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.dev-public-1.id

tags = {
  Name = "gw NAT"
}
}


#route table for NAT gateway
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "Private route table"
  }
}