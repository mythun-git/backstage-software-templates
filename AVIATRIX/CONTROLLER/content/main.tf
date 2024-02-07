terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      version = "3.1.4"
    }
  }
}

resource "aws_eip" "controller_eip" {
  domain = "vpc"
  tags   = local.common_tags
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.aviatrix_controller.id
  allocation_id = aws_eip.controller_eip.id
}

resource "aws_network_interface" "eni_controller" {
  subnet_id      = var.subnet_id
  security_groups = [var.security_group_id]
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}controller_network_interface"
  })
  lifecycle {
    ignore_changes = [tags, security_groups, subnet_id]
  }
}

data "aws_subnet" "controller_subnet" {
  id = var.subnet_id
}

resource "aws_instance" "aviatrix_controller" {
  ami                     = local.ami_id
  instance_type           = var.instance_type
  iam_instance_profile    = local.ec2_role_name
  disable_api_termination = var.termination_protection
  availability_zone       = data.aws_subnet.controller_subnet.availability_zone

  network_interface {
    network_interface_id = aws_network_interface.eni_controller.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    kms_key_id            = var.root_volume_kms_key_id
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = local.controller_name
  })

  lifecycle {
    ignore_changes = [
      ami, key_name, user_data, network_interface
    ]
  }
}
