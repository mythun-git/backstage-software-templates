provider "aws" {
  region = "${{ values.bucketRegion }}"
}

resource "aws_s3_bucket" "${{values.bucketName}}"{
  bucket = "${{ values.bucketName }}"
  
}

resource "aws_s3_access_point" "msaccesspoint" {
  name          = "access-point"
  bucket        = aws_s3_bucket.${{values.bucketName}}.bucket 
  vpc_configuration {
    vpc_id = "vpc-005aa4d379e350404"
  }
}
