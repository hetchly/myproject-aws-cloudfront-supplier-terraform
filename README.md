# Terraform module to provision an AWS CloudFront Distribution

## Prerequisites
Provision an S3 bucket to store Terraform State and DynamoDB for state-lock
using https://github.com/jrdalino/aws-tfstate-backend-terraform

## Usage
- Replace variables in terraform.tfvars
- Replace variables in state_config.tf
- Initialize, Review Plan and Apply
```
$ terraform init
$ terraform plan
$ terraform apply
```

## Inputs
| Name | Description |
|------|-------------|
| | |

## Outputs
| Name | Description |
|------|-------------|
| | |

## (In Progress) Module Usage
Include this repository as a module in your existing terraform code:
```
module "cloudfront" {
  source = "git::https://github.com/jrdalino/aws-cloudfront-terraform.git?ref=master"
}
```

## Notes: Using AWS CLI
- Step 1: Create an S3 Bucket for Storing Content
```
$ aws s3 mb s3://jrdalino-myproject-customer-web
```

- Step 2: Create a CloudFront Access Identity
```
$ aws cloudfront create-cloud-front-origin-access-identity \
--cloud-front-origin-access-identity-config CallerReference=Customer,Comment=Customer
```

- Step 3: Create the S3 Bucket Policy Input File
```
$ mkdir aws-cli
$ vi ~/environment/myproject-customer-web/aws-cli/website-bucket-policy.json
```
```
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity EUUQAM3AZAFRN"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::jrdalino-myproject-customer-web/*"
        }
    ]
}
```

- Step 4: Add a public bucket policy to allow CloudFront
```
$ aws s3api put-bucket-policy \
--bucket jrdalino-myproject-customer-web \
--policy file://~/environment/myproject-customer-web/aws-cli/website-bucket-policy.json
```

- Step 5: Publish the Website Content to S3
```
$ cd ~/environment/myproject-customer-web/dist
$ aws s3 cp . s3://jrdalino-myproject-customer-web/ --recursive
```

- Step 6: Create the CloudFront Distribution input file
```
$ cd ~/environment/myproject-customer-web
$ mkdir aws-cli
$ vi ~/environment/myproject-customer-web/aws-cli/website-cloudfront-distribution.json
```
```
{
  "CallerReference": "MyProjectCustomerWeb",
  "Aliases": {
    "Quantity": 0
  },
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "MyProjectCustomerWeb",
        "DomainName": "jrdalino-myproject-customer-web.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": "origin-access-identity/cloudfront/EUUQAM3AZAFRN"
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "MyProjectCustomerWeb",
    "ForwardedValues": {
      "QueryString": true,
      "Cookies": {
        "Forward": "none"
      }
    },
    "TrustedSigners": {
      "Enabled": false,
      "Quantity": 0
    },
    "ViewerProtocolPolicy": "allow-all",
    "MinTTL": 0,
    "MaxTTL": 0,
    "DefaultTTL": 0
  },
  "CacheBehaviors": {
    "Quantity": 0
  },
  "Comment": "",
  "Logging": {
    "Enabled": false,
    "IncludeCookies": true,
    "Bucket": "",
    "Prefix": ""
  },
  "PriceClass": "PriceClass_All",
  "Enabled": true
}
```

- Step 7: Create CloudFront Distribution
```
$ aws cloudfront create-distribution \
--distribution-config file://~/environment/myproject-customer-web/aws-cli/website-cloudfront-distribution.json
$ aws cloudfront list-distributions
```

- Step 8: Enable CORS on S3 and CloudFront
- Cloudfront: https://aws.amazon.com/premiumsupport/knowledge-center/no-access-control-allow-origin-error/
- S3: https://docs.aws.amazon.com/AmazonS3/latest/user-guide/add-cors-configuration.html
```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>HEAD</AllowedMethod>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedHeader>*</AllowedHeader>
</CORSRule>
</CORSConfiguration>
```

- Step 9: Test functionality of Frontend + Backend
```
$ curl d5ny4mdta1kxt.cloudfront.net
```

- (Optional) Clean up
```
$ aws s3 rm s3://jrdalino-myproject-customer-web --recursive
$ aws s3 rb s3://jrdalino-myproject-customer-web --force
$ rm ~/environment/myproject-customer-web/aws-cli/website-bucket-policy.json
$ disable cloudfront distribution
$ delete cloudfront distribution
$ aws cloudfront delete-cloud-front-origin-access-identity --id EXZ8BOEUVCLQY
$ rm ~/environment/myproject-customer-web/aws-cli/website-cloudfront-distribution.json
```

## Reference
- https://medium.com/modern-stack/5-minute-static-ssl-website-in-aws-with-terraform-76819a12d412