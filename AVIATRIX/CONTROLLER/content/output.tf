output private_ip {
  value       = aws_instance.aviatrix_controller.private_ip
  description = "Private IP of the controller"
}

output public_ip {
  value       = aws_eip.controller_eip.public_ip
  description = "Public IP of the controller"
}

output vpc_id {
  value       = var.vpc_id
  description = "VPC where Aviatrix controller was built"
}

output subnet_id {
  value       = var.subnet_id
  description = "Subnet where Aviatrix controller was built"
}

output security_group_id {
  value       = var.security_group_id
  description = "Security group id used by Aviatrix controller"
}

output instance_id {
  value       = aws_instance.aviatrix_controller.id
  description = "Controller instance ID"
}
