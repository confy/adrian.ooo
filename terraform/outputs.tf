output "codeship_access_key_id" {
 value       = "${aws_iam_access_key.codeship.id}"
 description = "AWS Access Key ID for Continuous Delivery user"
}
output "codeship_access_key_secret" {
 value       = "${aws_iam_access_key.codeship.secret}"
 description = "AWS Access Key Secret for Continuous Delivery user"
}
output "cloudfront_hostname" {
 value       = "${module.hugosite.cloudfront_hostname}"
 description = "CloudFront DNS hostname to create a CNAME to with DNS provider"
}