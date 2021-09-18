#Change profile to the AWS credentials profile you want to use.
provider "aws" {
  region  = var.aws_region
  profile = "fillupio"
}