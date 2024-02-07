provider "aws" {
  region  = "${{ values.region }}"
}
# Specify your existing VPC ID
variable "vpc_id" {
  type    = string
  default = "${{ values.vpcId }}"
}

# Specify your existing security group ID
variable "security_group_id" {
  type    = string
  default = "${{ values.securityGroupId }}"
}

# Specify your existing subnet group ID
resource "aws_db_instance" "my_${{ values.dbIdentifierName}}" {
    identifier             = "${{ values.dbIdentifierName }}"
    instance_class         = "${{ values.instanceClass }}"
    allocated_storage      = ${{ values.storageSize }}
    db_name                = "${{ values.databaseName}}"
    storage_type           = "${{ values.storageType}}"
    engine                 = "postgres"
    engine_version         = "${{ values.engineVersion}}"
    skip_final_snapshot    = true
    publicly_accessible    = ${{ values.publiclyAccessible}}
    username               = "${{ values.dbUserName }}"
    password               = "${{ values.dbPassword }}"
    vpc_security_group_ids = [var.security_group_id]
    db_subnet_group_name = "${{ values.subsetGroupName }}"
    #vpc_id                 = var.vpc_id

    tags = {
        name = "My PostgresSQL"
        Environment = "${{ values.env }}"
        region      = "${{ values.region }}"   
    }
}
