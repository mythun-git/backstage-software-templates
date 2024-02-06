provider "aws" {
  region = "${{ values.bucketRegion }}"
}

resource "aws_s3_bucket" "${{values.bucketName}}" {
  bucket = "${{ values.bucketName }}"
}

resource "aws_s3_access_point" "${{ values.accessPointName }}" {
  name          = "${{values.accessPointName}}"
  bucket        = aws_s3_bucket.${{values.bucketName}}.bucket 
  vpc_configuration {
    vpc_id = "${{values.vpcId}}"
  }
}
