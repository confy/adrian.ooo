terraform {
  backend "remote" {
    organization = "confy"
    workspaces {
      name = "adrian-ooo"
    }
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "3.59.0"
      }
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
module "hugosite" {
  source              = "github.com/fillup/terraform-hugo-s3-cloudfront"
  aws_region          = "us-east-1"
  aliases             = ["www.adrian.ooo", "adrian.ooo"]
  bucket_name         = "www.adrian.ooo"
  cert_domain         = "*.adrian.ooo"
  deployment_user_arn = "arn:aws:iam::526286878664:user/adrian-ooo"
  default_root_object = null
  error_document      = "index.html"
  custom_error_response = [
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    },
  ]
}
