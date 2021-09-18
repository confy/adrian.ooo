variable "aliases" {
 type        = list(string)
 default     = ["www.adrian.ooo", "adrian.ooo"]
 description = "List of hostname aliases"
}
variable "aws_region" {
 default = "us-east-1"
}
variable "bucket_name" {
 default = "www.adrian.ooo"
}
variable "codeship_username" {
 default = "codeship"
}
variable "cert_domain_name" {
 default = "*.adrian.ooo"
}
variable "aws_zone_id" {
 default     = "adrian.ooo"
 description = "AWS Route 53 Zone ID for DNS"
}
variable "hostname" {
 default     = "www.adrian.ooo"
 description = "Full hostname for Route 53 entry"
}