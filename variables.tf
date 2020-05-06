# General
variable "aws_region" {
  type        = string
  description = "Used AWS Region."    
}

variable "aws_account" {
  type        = string
  description = "Used AWS Account."    
}

# S3 Bucket
variable "aws_s3_bucket_bucket" {
  type        = string
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."    
}

# CloudFront Origin Access Identity
variable "aws_cloudfront_origin_access_identity_comment" {
  type        = string
  description = "(Optional) - An optional comment for the origin access identity."    
}