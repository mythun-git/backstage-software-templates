terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      version = "3.1.4"
    }
  }
}

provider "aviatrix" {
   controller_ip           = "${{ values.controllerIP }}"
   username                = "${{ values.userName }}"
   password                = "${{ values.password }}"
   skip_version_validation = true
 }

# Create an Aviatrix Smart Group
resource "aviatrix_smart_group" "${{ values.smartGroupName }}_ip" {
  name = "${{ values.smartGroupName }}"
  selector {
    match_expressions {
      type         = "${{ values.smartGroupType }}"
      account_name = "${{ values.smartGroupAccName }}"
      name = "${{ values.smartGroupName }}"
    }
  }
}
