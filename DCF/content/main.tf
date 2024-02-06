
# # Configure Aviatrix provider
 provider "aviatrix" {
   controller_ip           = ${{ values.controllerIP }}
   username                = ${{ values.userName }}
   password                = ${{ values.password }}
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
 
resource "aviatrix_distributed_firewalling_policy_list" "test2" {
  policies {
    name             = ${{ values.dfPolicyName1 }}
    action           = ${{ values.action1 }}
    priority         = 2
    protocol         = "ANY"
    logging          = false
    watch            = false
    src_smart_groups = [
      "ce4dd1b6-df8e-4dd0-a5f0-9aa08739c521"
    ]
    dst_smart_groups = [
      "7f2c099d-8fd3-4ac4-93f0-29f132707bb7"
    ]
  }

  policies {
    name             = ${{ values.dfPolicyName2 }}
    action           = ${{ values.action2 }}
    priority         = 1
    protocol         = "ANY"
    logging          = false
    watch            = false
    src_smart_groups = [
      "7f2c099d-8fd3-4ac4-93f0-29f132707bb7"
    ]
    dst_smart_groups = [
      "ce4dd1b6-df8e-4dd0-a5f0-9aa08739c521"
    ]
  }
 
}
