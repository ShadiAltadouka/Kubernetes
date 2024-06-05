// VPC
resource "aws_vpc" "tf-kube-vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf-kube-vpc"
  }
}

// SUBNETS
resource "aws_subnet" "tf-subnet1" {
  vpc_id                  = aws_vpc.tf-kube-vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-subnet1"
  }
}
resource "aws_subnet" "tf-subnet2" {
  vpc_id                  = aws_vpc.tf-kube-vpc.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-subnet2"
  }
}

// INTERNET GATEWAY
resource "aws_internet_gateway" "tf-igw1" {
  vpc_id = aws_vpc.tf-kube-vpc.id

  tags = {
    Name = "tf-igw1"
  }

}

// ROUTE TABLE
resource "aws_route_table" "tf-rt1" {
  vpc_id = aws_vpc.tf-kube-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw1.id
  }

  tags = {
    Name = "tf-rt1"
  }

}

// ROUTE TABLE SUBNET ASSOCIATION
resource "aws_route_table_association" "tf-rta1" {
  route_table_id = aws_route_table.tf-rt1.id
  subnet_id      = aws_subnet.tf-subnet1.id

}
resource "aws_route_table_association" "tf-rta2" {
  route_table_id = aws_route_table.tf-rt1.id
  subnet_id      = aws_subnet.tf-subnet2.id

}