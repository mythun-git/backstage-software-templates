# Create an Aviatrix AWS Spoke Gateway
 provider "aviatrix" {
    controller_ip           = "${{ values.controllerIP }}"
    username                = "${{ values.userName }}"
    password                = "${{ values.password }}"
   skip_version_validation = true
 }
 
terraform {
  required_providers {
    aviatrix = {
    source = "AviatrixSystems/aviatrix"
    version = "3.1.4"
    }
  }
}
resource "aviatrix_spoke_gateway" "test_spoke_gateway_aws" {
  cloud_type        = 1
  account_name       = "${{ values.aviatrixGwAccountName }}"
  gw_name            = "${{ values.gatewayName }}"
  vpc_id            = "${{ values.vpcId }}"
  vpc_reg            = "${{ values.region }}"
  gw_size            = "${{ values.gatewaySize }}"
  subnet            =  "${{ values.subnet }}"
  single_ip_snat    = false
  manage_ha_gateway = false
  tags              = {
    name = "spoke-gw-app1"
  }
}
