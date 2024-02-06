terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "${{ values.region }}"
}

// To Generate Private Key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "key_name" {
  description = "Name of the SSH key pair"
}

// Create Key Pair for Connecting EC2 via SSH
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

// Save PEM file locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = var.key_name
}



resource "aws_instance" "public_instance" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "${{ values.instanceType }}"
  key_name               = aws_key_pair.key_pair.key_name
  subnet_id              = "subnet-0b620eefbe9679408"
  vpc_security_group_ids = ["sg-04ffd5db7addf4598"]
  associate_public_ip_address = true

  
  tags = {
    Name = "APP1 EC2"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
}
