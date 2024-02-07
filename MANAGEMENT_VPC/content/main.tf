resource "aws_vpc" "management_vpc" {
  cidr_block = "${{ values.vpcCIDR }}"

  tags = {
    Name = "${{ values.vpcTagName }}"
  }
}

resource "aws_subnet" "mgt_public_subnet" {
  vpc_id            = aws_vpc.management_vpc.id
  cidr_block        = "${{ values.awsPublicSubnetCIDR }}"
  availability_zone = "${{ values.awsPublicSubnetAvlZone }}"

  tags = {
    Name = "${{ values.awsPublicSubnetTagName }}"
  }
}

resource "aws_subnet" "mgt_private_subnet" {
  vpc_id            = aws_vpc.management_vpc.id
  cidr_block        = "${{ values.awsPrivateSubnetCIDR }}"
  availability_zone = "${{ values.awsPrivateSubnetAvlZone }}"

  tags = {
    Name = "${{ values.awsPrivateSubnetTagName }}"
  }
}

resource "aws_internet_gateway" "mgt_ig" {
  vpc_id = aws_vpc.management_vpc.id

  tags = {
    Name = "${{ values.internetGatewayTagName }}"
  }
}

resource "aws_route_table" "mgt_rt" {
  vpc_id = aws_vpc.management_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mgt_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.mgt_ig.id
  }

  tags = {
    Name ="${{ values.routeTableTagName }}"
  }
}

resource "aws_route_table_association" "management_1_rt_a" {
  subnet_id      = aws_subnet.mgt_public_subnet.id
  route_table_id = aws_route_table.mgt_rt.id
}

resource "aws_security_group" "mgt_sg" {
  name   = "${{ values.awsSecurityGroupTagName }}"
  vpc_id = aws_vpc.management_vpc.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
