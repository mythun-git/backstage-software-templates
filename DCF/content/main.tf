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
 
# Create an Aviatrix Distributed Firewalling Policy List
 
resource "aviatrix_distributed_firewalling_policy_list" "${{ values.dfPolicyName1 }}" {
  policies {
    name             = "${{ values.dfPolicyName1 }}"
    action           = "${{ values.action1 }}"
    priority         = 2
    protocol         = "ANY"
    logging          = false
    watch            = false
    src_smart_groups = [
      "${{ values.sourceSmartGroup }}"
    ]
    dst_smart_groups = [
      "${{ values.destinationSmartGroup }}"
    ]
  }

  policies {
    name             = "${{ values.dfPolicyName2 }}"
    action           = "${{ values.action2 }}"
    priority         = 1
    protocol         = "ANY"
    logging          = false
    watch            = false
    src_smart_groups = [
      "${{ values.destinationSmartGroup }}"
    ]
    dst_smart_groups = [
      "${{ values.sourceSmartGroup }}"
    ]
  }
 
}
