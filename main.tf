terraform {
  backend "remote" {
    organization = "confy"
    workspaces {
      name = "adrian-ooo"
    }
  }
}

module "hugosite" {
  source              = "github.com/fillup/terraform-hugo-s3-cloudfront"
  aliases             = ["www.adrian.ooo", "adrian.ooo"]
  bucket_name         = "www.adrian.ooo"
  cert_domain         = "*.adrian.ooo"
  deployment_user_arn = "arn:aws:iam::111122223333:person"
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