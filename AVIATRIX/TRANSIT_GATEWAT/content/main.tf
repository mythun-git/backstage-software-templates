
provider "aws" {
  region = local.region
}

locals {
  name   = "ex-tgw-${replace(basename(path.cwd), "_", "-")}"
  region = "${{ values.region }}"

  tags = {
    Example    = local.name
    GithubRepo = "${{ values.gitHubRepo }}"
    GithubOrg  = "${{ values.gitHubOrg }}"
  }
}

################################################################################
# Transit Gateway Module
################################################################################

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name            = local.name
  description     = "${{ values.tgwDescription}}"
  amazon_side_asn = ${{ values.amazonSideAsn }}

  transit_gateway_cidr_blocks = ["${{ cidrBlocks }}"]

  # When "true" there is no need for RAM resources if using multiple AWS accounts
  enable_auto_accept_shared_attachments = ${{ values.enableAutoAcceptAttachments }}

  # When "true", allows service discovery through IGMP
  enable_multicast_support = ${{ values.enableMulticastSupport }}

  vpc_attachments = {
    vpc = {
      vpc_id       = module.vpc.vpc_id
      subnet_ids   = module.vpc.private_subnets
      dns_support  = ${{ values.vpcAttachDnsSupport }}
      ipv6_support = true

      transit_gateway_default_route_table_association = ${{ vlaues.tgDefaultRouteTableAssociation }}
      transit_gateway_default_route_table_propagation = ${{ vlaues.tgDefaultRouteTablePropagation }}

      tgw_routes = [
        {
          destination_cidr_block = "${{ values.tgwRoute1 }}"
        },
        {
          blackhole              = ${{ values.tgwBlackhole }}
          destination_cidr_block = "${{ values.tgwRoute2 }}"
        }
      ]
    }  
  }

  ram_allow_external_principals = ${{ values.ramAllowExternalPrincipals }}
  ram_principals                = [ ${{ values.ramPrincipals }} ]

  tags = local.tags
}

################################################################################
# Supporting resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = "${{ values.vpcCidr }}"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]

  enable_ipv6                                    = ${{ values.enableIpv6 }}
  private_subnet_assign_ipv6_address_on_creation = ${{ values.assignIpv6AddressOnCreation }}
  private_subnet_ipv6_prefixes                   = [0, 1, 2]

  tags = local.tags
}
