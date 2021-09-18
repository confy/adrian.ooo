module "hugosite" {
  source              = "fillup/hugo-s3-cloudfront/aws"
  aliases             = ["${var.aliases}"]
  aws_region          = var.aws_region
  bucket_name         = var.bucket_name
  cert_domain         = var.cert_domain_name
  deployment_user_arn = "arn:aws:iam::526286878664:user/adrian-ooo"
  cf_default_ttl      = "0"
  cf_max_ttl          = "0"
}
#Create IAM user with limited permissions for Codeship to deploy site to S3
resource "aws_iam_user" "codeship" {
  name = var.codeship_username
}
resource "aws_iam_access_key" "codeship" {
  user = aws_iam_user.codeship.name
}
data "template_file" "policy" {
  template = file("${path.module}/bucket-policy.json")
  vars {
    bucket_name = var.bucket_name
  }
}
resource "aws_iam_user_policy" "codeship" {
  policy = data.template_file.policy.rendered
  user   = aws_iam_user.codeship.name
}
#Add record to Route 53
resource "aws_route53_record" "www" {
  zone_id = var.aws_zone_id
  name    = var.hostname
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.hugosite.cloudfront_hostname}"]
}