provider "aws" {
  profile = "default"
  region  = "${{ values.region }}"
}

resource "aws_vpc" "${replace(values.region, "-", "_")}_region_vpc" {
  cidr_block = "10.0.30.0/24"

  tags = {
    Name = "APP1 VPC"
  }
}

resource "aws_subnet" "us_er_public_subnet" {
  vpc_id            = aws_vpc.${replace(${{ values.region }}, "-", "_")}_region_vpc.id
  cidr_block        = "10.0.30.0/25"
  availability_zone = "us-east-1a"

  tags = {
    Name = "APP1 VPC Public Subnet"
  }
}

resource "aws_subnet" "us_er_private_subnet" {
  vpc_id            = aws_vpc.${replace(values.region, "-", "_")}_region_vpc.id
  cidr_block        = "10.0.30.128/25"
  availability_zone = "us-east-1a"

  tags = {
    Name = "APP1 VPC Private Subnet"
  }
}

resource "aws_internet_gateway" "us_er_ig" {
  vpc_id = aws_vpc.${replace(values.region, "-", "_")}_region_vpc.id

  tags = {
    Name = "APP1 VPC Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.${replace(values.region, "-", "_")}_region_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.us_er_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.us_er_ig.id
  }

  tags = {
    Name = "APP1 VPC Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.us_er_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "APP1 VPC SG"
  vpc_id = aws_vpc.${replace(values.region, "-", "_")}_region_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "APP1 VPC SG"
  }
}
