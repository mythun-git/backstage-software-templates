terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      version = "3.1.3"
    }
  }
}

# Configure Aviatrix provider
provider "aviatrix" {
  controller_ip           = "${{ values.controllerIP }}"
  username                = "${{ values.userName }}"
  password                = "${{ values.password }}"
  skip_version_validation = true
}

provider "aws" {
  profile = "default"
  region  = "${{ values.region }}"
}
resource "aviatrix_gateway" "aviatrix_gateway_aws" {
  cloud_type         = 1
  account_name       = "${{ values.aviatrixGwAccountName }}"
  gw_name            = "${{ values.gatewayName }}"
  vpc_id             = "${{values.vpcId}}"
  vpc_reg            = "${{ values.region }}"
  gw_size            = "${{ values.gatewaySize }}"
  subnet             =  "${{ values.gatewaySubnet }}"
  #peering_ha_subnet  = "10.2.1.0/24"
  #peering_ha_gw_size = "${{ values.gatewaySize }}"
}
