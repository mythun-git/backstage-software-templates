terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      version = "3.1.4"
    }
  }
}

resource "aws_eip" "copilot_eip" {
  count = var.private_mode == false ? 1 : 0
  tags  = local.common_tags
}

resource "aws_eip_association" "eip_assoc" {
  count         = var.private_mode == false ? 1 : 0
  instance_id   = aws_instance.aviatrixcopilot.id
  allocation_id = aws_eip.copilot_eip[0].id
}

resource "aws_network_interface" "eni-copilot" {
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}copilot_network_interface"
  })

  lifecycle {
    ignore_changes = [
      security_groups,
    ]
  }
}

data "aws_subnet" "subnet" {
  id = var.subnet_id
}

resource "aws_instance" "aviatrixcopilot" {
  ami               = local.ami_id
  instance_type     = local.instance_type
  availability_zone = data.aws_subnet.subnet.availability_zone
  user_data         = <<EOF
#!/bin/bash
jq '.config.controllerIp="${local.controller_ip}" | .config.controllerPublicIp="${local.controller_ip}" | .config.isCluster=${var.is_cluster}' /etc/copilot/db.json > /etc/copilot/db.json.tmp
mv /etc/copilot/db.json.tmp /etc/copilot/db.json
EOF

  network_interface {
    network_interface_id = aws_network_interface.eni-copilot.id
    device_index         = 0
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = merge(local.common_tags, {
    Name = var.copilot_name != "" ? var.copilot_name : (var.type == "Copilot" ? "${local.name_prefix}AviatrixCopilot" : "${local.name_prefix}AviatrixCopilot_ARM")
  })
}

resource "null_resource" "wait_for_copilot" {
  triggers = {
    copilot = aws_instance.aviatrixcopilot.public_ip
  }
  provisioner "local-exec" {
    when    = create
    command = <<EOF
echo "Waiting for Copilot..."
count=0
until [ "$(curl -ks https://${try(aws_eip.copilot_eip[0].public_ip, "")}/api/info/updateStatus | jq -r '.status')" = "finished" ]
do
  sleep 10
  count=$((count+1))
  if [ $count -eq 60 ]; then
    break
  fi
done
echo "Copilot is online."
      EOF
  }
  depends_on = [aws_instance.aviatrixcopilot]
}

resource "aws_ebs_volume" "default" {
  count             = var.default_data_volume_name == "" ? 0 : 1
  availability_zone = data.aws_subnet.subnet.availability_zone
  size              = var.default_data_volume_size
  tags = {
    Name = "${local.name_prefix}copilot_default_data_volume"
  }
}

resource "aws_volume_attachment" "default" {
  count       = var.default_data_volume_name == "" ? 0 : 1
  device_name = var.default_data_volume_name
  volume_id   = aws_ebs_volume.default[0].id
  instance_id = aws_instance.aviatrixcopilot.id
}

resource "aws_volume_attachment" "ebs_att" {
  for_each    = var.additional_volumes
  device_name = each.value.device_name
  volume_id   = each.value.volume_id
  instance_id = aws_instance.aviatrixcopilot.id
}
